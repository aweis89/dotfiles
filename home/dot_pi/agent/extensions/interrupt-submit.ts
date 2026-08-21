import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function interruptSubmit(pi: ExtensionAPI) {
  let pendingSubmission: string | undefined;

  pi.registerShortcut("ctrl+enter", {
    description: "Submit input and interrupt the current agent run",
    handler: (ctx) => {
      const text = ctx.ui.getEditorText().trim();
      if (!text) return;

      if (pendingSubmission !== undefined) {
        ctx.ui.notify("An interrupting submission is already pending", "warning");
        return;
      }

      ctx.ui.setEditorText("");

      if (ctx.isIdle()) {
        pi.sendUserMessage(text);
        return;
      }

      pendingSubmission = text;
      ctx.abort();
    },
  });

  pi.on("agent_settled", (_event, ctx) => {
    if (pendingSubmission === undefined) return;

    const text = pendingSubmission;
    pendingSubmission = undefined;
    pi.sendUserMessage(text, ctx.isIdle() ? undefined : { deliverAs: "steer" });
  });
}
