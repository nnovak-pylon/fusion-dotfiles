import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * /clear — alias for /new.
 *
 * Starts a new session, discarding the current conversation history
 * (the same behaviour as the built-in `/new`).
 */
export default function (pi: ExtensionAPI) {
  pi.registerCommand("clear", {
    description: "Start a new session (alias for /new)",
    handler: async (_args, ctx) => {
      await ctx.newSession();
    },
  });
}
