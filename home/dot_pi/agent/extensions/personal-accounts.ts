import type { Api, Model, Provider } from "@earendil-works/pi-ai";
import { builtinProviders } from "@earendil-works/pi-ai/providers/all";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Second login per upstream vendor.
 *
 * Pi stores exactly one credential per provider id in ~/.pi/agent/auth.json, so
 * "two Anthropic accounts" has to mean "two provider ids that both talk to
 * Anthropic". These clones reuse the built-in providers' auth (including the
 * real Claude Pro/Max and ChatGPT OAuth flows), models, and streaming, and only
 * swap the id, so `/login pa` and `/login pc` authenticate personal accounts
 * without touching the work credentials stored under `anthropic`/`openai-codex`.
 */
const CLONES = [
	{ source: "anthropic", id: "pa", name: "Personal Anthropic" },
	{ source: "openai-codex", id: "pc", name: "Personal Codex" },
] as const;

/**
 * Mirrors pi-ai's `defaultSupportsToolReferences`, which keys off
 * `model.provider === "anthropic"` and would therefore silently disable native
 * tool references (tool search) for the renamed clone. Pin the value the model
 * would have had under its original provider id so behavior stays identical.
 */
function defaultSupportsToolReferences(model: Model<Api>): boolean {
	if (model.id.includes("haiku")) return false;
	const version = model.id.match(/^claude-(?:opus|sonnet|fable)-(\d+)(?:-(\d+))?(?:-|$)/);
	if (!version) return false;
	const major = Number(version[1]);
	const minor = version[2] && version[2].length < 8 ? Number(version[2]) : 0;
	return major > 4 || (major === 4 && minor >= 5);
}

function rebrandModel(model: Model<Api>, providerId: string): Model<Api> {
	const compat = model.compat as { supportsToolReferences?: boolean } | undefined;
	const needsToolReferencePin =
		model.provider === "anthropic" &&
		model.api === "anthropic-messages" &&
		compat?.supportsToolReferences === undefined;

	return {
		...model,
		provider: providerId,
		...(needsToolReferencePin
			? {
					compat: {
						...compat,
						supportsToolReferences: defaultSupportsToolReferences(model),
					},
				}
			: {}),
	} as Model<Api>;
}

function cloneProvider(source: Provider, id: string, name: string): Provider {
	let models = source.getModels().map((model) => rebrandModel(model, id));

	return {
		...source,
		id,
		name,
		getModels: () => models,
		// Dead code for anthropic/openai-codex today (static catalogs), but keeps
		// the clone correct if either provider gains dynamic model discovery.
		...(source.refreshModels
			? {
					refreshModels: async (context: Parameters<NonNullable<Provider["refreshModels"]>>[0]) => {
						await source.refreshModels?.(context);
						models = source.getModels().map((model) => rebrandModel(model, id));
					},
				}
			: {}),
	};
}

export default function personalAccounts(pi: ExtensionAPI) {
	const sources = new Map(builtinProviders().map((provider) => [provider.id, provider]));

	for (const { source, id, name } of CLONES) {
		const builtin = sources.get(source);
		if (!builtin) continue;
		pi.registerProvider(cloneProvider(builtin, id, name));
	}
}
