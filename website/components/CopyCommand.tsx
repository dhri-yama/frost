"use client";

import { useRef, useState } from "react";

/** A shell command with a copy button. The button says what happened ("Copied") for a moment, then goes back. */
export default function CopyCommand({ command }: { command: string }) {
  const [state, setState] = useState<"idle" | "copied" | "failed">("idle");
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  async function copy() {
    try {
      await navigator.clipboard.writeText(command);
      setState("copied");
    } catch {
      setState("failed");
    }
    if (timer.current) clearTimeout(timer.current);
    timer.current = setTimeout(() => setState("idle"), 2200);
  }

  return (
    <div className="command">
      <code className="command__text">{command}</code>
      <button type="button" className="command__copy" onClick={copy}>
        {state === "copied" ? "Copied" : state === "failed" ? "Press ⌘C to copy" : "Copy"}
      </button>
      <span className="visually-hidden" role="status">
        {state === "copied" ? "Command copied to the clipboard" : ""}
      </span>
    </div>
  );
}
