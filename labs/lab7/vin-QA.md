# vin's QA

## 1. How could we handle "agent got stuck" scenarios?

Kubernetes will partially hadle this.
Also the Kubernetes liveness/readiness probes on agent pods will be implemnted

One more option-  Request timeouts on HTTPRoutes via Gateway API timeout policies at the agentgateway layer

## 2. Any automatic timeout/circuit breaker patterns from this framework?

agentgateway (v2.2.1) provides:

- Failover across priority groups (triggered on 429 responses only)
- P2C (Power of Two Choices) load balancing that degrades health scores for failing backends
- Rate limiting (request-based and token-based)

## 3. How does kgateway handle model failover?

agentgateway uses priority groups in `AgentgatewayBackend`:

- Models listed in priority order — first group gets all traffic
- If models return 429 (rate limited), traffic fails over to the next priority group
- Within a group, P2C balances based on health, latency, and load

## 4. Can we automatically switch from OpenAI to Claude to local model?

Yes — agentgateway's priority groups enable this:

- Priority 1: OpenAI gpt-4o
- Priority 2: Anthropic Claude
- Priority 3: Local model (e.g., via Bedrock or self-hosted)

The repo already configures three providers in `kagent.yaml`: OpenAI, Gemini, and Bedrock (with separate `ModelConfig` CRDs). The catch is the 429-only failover limitation — if OpenAI returns 500 instead of 429, it won't auto-switch, just lowers OpenAI's health score.

## 5. Could we seamlessly handle response formats from these providers?

agentgateway normalizes this. It speaks the OpenAI-compatible `/v1/chat/completions` API on the frontend and translates to each provider's native format on the backend. The `URLRewrite` filter in HTTPRoutes rewrites paths to the correct provider endpoint.

Already set up in the repo — the Bedrock `ModelConfig` uses `openai.gpt-oss-20b-1:0` with an OpenAI-compatible base URL pointing at Bedrock.

## 6. Can we version the agents built from kagent?

Partially. Two patterns in the repo:

- **Declarative agents** (`k8s-a2a-agent`): defined as `Agent` CRDs in YAML — versioned via Git/OCI artifacts through Flux. Every `make push` creates a new semver tag.
- **BYO agents** (`triage-agent`, `rca-agent`): reference container images — versioned via image tags.

The `agentregistry` component could potentially serve as a version registry.

## 7. Any blue/green or canary deployment patterns for agents?

agentgateway supports traffic splitting (weight-based distribution) via `AgentgatewayBackend`:

- **Canary**: 90/10 split — route 90% to agent v1, 10% to agent v2
- **Blue/green**: flip weights from 100/0 to 0/100

Combined with Flux GitOps: update weights in YAML, push, cluster reconciles. For BYO agents, run two Deployments with different image tags and split traffic via HTTPRoute weights.

## 8. What's the fastmcp-python framework?

FastMCP is a Python framework for building MCP (Model Context Protocol) servers. FastMCP 1.0 was incorporated into the official MCP Python SDK. FastMCP 2.0 is the actively maintained version. Decorate Python functions as MCP tools/resources with minimal boilerplate — the framework handles JSON-RPC, session state, and protocol formatting.


## 9. Is it the easiest path to MCP?

For Python developers, yes. Write a function, add a `@tool` decorator, FastMCP handles the rest. Compare to raw MCP SDK where you manage JSON-RPC manually.

For non-Python: `@modelcontextprotocol/server-everything` npm package (used in this repo's `mcps.yaml`) is the JS equivalent. The repo's MCP server uses npx/stdio — simpler for prototyping, less flexible for production.

## 10–11. FinOps: how much control? Token level / per agent level?

agentgateway provides:

- **Token-level**: tracks input/output tokens per request via `agentgateway_gen_ai_client_token_usage` Prometheus metric, labeled by model, provider, operation type
- **Per-user/per-key**: virtual key management with independent token budgets per API key, time-windowed refill (hourly, daily)
- **Per-route**: different HTTPRoutes can have different `AgentgatewayPolicy` resources with separate budget limits
- **Cost calculation**: multiply token counts by provider pricing (exposed via PromQL)
- **Alerting**: Prometheus AlertManager rules for spending thresholds

Per-agent budgets aren't first-class yet — map by giving each agent its own API key or routing through a dedicated HTTPRoute, then apply rate limits to that route/key.

## 12. Can I implement custom cost controls?

Yes. Building blocks:

- Token-based rate limiting (global or local) via `AgentgatewayPolicy`
- Virtual keys with per-key token budgets and time windows
- Prometheus metrics + AlertManager for custom alerts
- OTel traces with per-request token counts
- Daily/hourly caps that reject requests with 429 when exhausted

For workflow-level logic (e.g., "stop agent if cumulative cost > $X across a multi-step workflow"), build in agent code or a sidecar — agentgateway operates at the request level, not workflow level.

## 13. Per-agent budgets or depth of token limits?

**Per-agent budgets**: achievable by assigning each agent a unique virtual key and setting token limits on that key. `AgentgatewayPolicy` with `type: TOKEN` keyed by `X-User-ID` or API key header.

**Depth/recursion limits** (e.g., "max 10 LLM calls per agent run"): not built into agentgateway or kagent. Implement in the agent's system prompt or application logic. agentgateway counts tokens, not call depth.

## 14. vLLM suitable for agents with many back-and-forth tool calls, or better for single-shot?

vLLM handles both — optimized for throughput on the serving side. For agentic workloads with many round trips, the key concern is KV cache reuse:

- Each tool-call round trip as a new request → vLLM recomputes prefix unless prefix caching is enabled
- With prefix caching on, subsequent turns sharing the same conversation prefix get significant speedups
- Ideally use sticky routing (same request → same vLLM instance) to maximize cache hits

vLLM works for agents, but enable prefix caching and sticky routing.

## 15. llm-d's scheduler — helps when agents make 15 LLM calls?

This is llm-d's sweet spot. Its intelligent scheduler (via Gateway API Inference Extension / EPP):

- **KV-cache-aware routing**: routes follow-up requests to the pod with cached prefix — turns 2–15 skip redundant prefill
- **Load-aware balancing**: avoids overloaded pods (unlike round-robin scattering 15 calls across 15 pods, killing cache reuse)
- **Queue-depth filtering**: excludes pods under memory pressure
- **Scoring**: ranks pods by cache hit potential + current load

For a 15-call agentic flow, llm-d routes all calls to the same pod (or small set), maximizing prefix cache hits and reducing latency on each subsequent call. Massive improvement over vanilla K8s load balancing for agentic workloads.

