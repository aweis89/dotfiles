import { getSupportedThinkingLevels } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function thinkingLevelShortcuts(pi: ExtensionAPI) {
	pi.registerShortcut("ctrl+p", {
		description: "Cycle to the previous thinking level",
		handler: (ctx) => {
			if (!ctx.model?.reasoning) {
				ctx.ui.notify("Current model does not support thinking", "warning");
				return;
			}

			const levels = getSupportedThinkingLevels(ctx.model);
			const currentIndex = levels.indexOf(pi.getThinkingLevel());
			const previousIndex = (currentIndex - 1 + levels.length) % levels.length;
			const previousLevel = levels[previousIndex];

			pi.setThinkingLevel(previousLevel);
			ctx.ui.notify(`Thinking level: ${previousLevel}`, "info");
		},
	});
}
