"use client";

import { useEffect, useState } from "react";

type Link = { href: string; label: string };

/** Stroke icons, 24x24. Generic shapes: this is a demo of a crowded menu bar, not anyone's real apps. */
const hideable = [
  { name: "Cloud sync", d: "M7 18h9.5a4 4 0 0 0 .6-7.96A5.5 5.5 0 0 0 6.4 9.5 4.3 4.3 0 0 0 7 18Z" },
  { name: "Chat", d: "M5 6.5A2.5 2.5 0 0 1 7.5 4h9A2.5 2.5 0 0 1 19 6.5v6a2.5 2.5 0 0 1-2.5 2.5H11l-4 3.5V15h-.0A2.5 2.5 0 0 1 5 12.5Z" },
  { name: "Microphone", d: "M12 14.5a3 3 0 0 0 3-3v-5a3 3 0 0 0-6 0v5a3 3 0 0 0 3 3ZM6.5 11.5a5.5 5.5 0 0 0 11 0M12 17v3" },
  { name: "Screen recorder", d: "M12 18a6 6 0 1 0 0-12 6 6 0 0 0 0 12ZM12 14a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z" },
  { name: "VPN", d: "M12 4 5.5 6.5v5c0 4 2.7 6.7 6.5 8.5 3.8-1.8 6.5-4.5 6.5-8.5v-5Z" },
];

function Icon({ d }: { d: string }) {
  return (
    <svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <path d={d} />
    </svg>
  );
}

/**
 * The page's top strip is a working menu bar. The chevron does what Frost's chevron does: it tucks the crowded icons away
 * and brings them back. After you bring them back they hide again on their own, as Frost's timer does.
 */
export default function MenuBar({ links, sourceUrl }: { links: Link[]; sourceUrl: string }) {
  const [hidden, setHidden] = useState(false);
  const [touched, setTouched] = useState(false);

  useEffect(() => {
    if (!touched || hidden) return;
    const t = setTimeout(() => setHidden(true), 8000);
    return () => clearTimeout(t);
  }, [touched, hidden]);

  return (
    <header className="menubar">
      <a className="menubar__skip" href="#main">Skip to content</a>
      <div className="menubar__left">
        <a className="menubar__brand" href="#top" aria-label="Frost, back to top">
          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
            <path d="M15 5 8 12l7 7" />
          </svg>
          <span>Frost</span>
        </a>
        <nav className="menubar__nav" aria-label="Page sections">
          {links.map((l) => (
            <a key={l.href} href={l.href} className="menubar__link">{l.label}</a>
          ))}
          <a href={sourceUrl} className="menubar__link">Source</a>
        </nav>
      </div>

      <div className="status" aria-label="Demo menu bar">
        <div className={`status__group${hidden ? " is-hidden" : ""}`} inert={hidden}>
          {hideable.map((i) => (
            <span key={i.name} className="status__icon" title={i.name}>
              <Icon d={i.d} />
              <span className="visually-hidden">{i.name}</span>
            </span>
          ))}
        </div>
        <button
          type="button"
          className={`status__chevron${hidden ? " is-collapsed" : ""}`}
          aria-expanded={!hidden}
          aria-label={hidden ? "Show the hidden menu bar icons" : "Hide the menu bar icons"}
          onClick={() => {
            setHidden((h) => !h);
            setTouched(true);
          }}
        >
          <Icon d="M14.5 6.5 9 12l5.5 5.5" />
        </button>
        <span className="status__icon" aria-hidden="true">
          <Icon d="M4 9.5a11 11 0 0 1 16 0M7 13a6.5 6.5 0 0 1 10 0M12 17.2h.01" />
        </span>
        <span className="status__icon" aria-hidden="true">
          <svg viewBox="0 0 24 24" width="19" height="19" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
            <rect x="3" y="8" width="16" height="8" rx="2.2" /><path d="M21 10.5v3" />
          </svg>
        </span>
        <span className="status__clock">Fri 11:48 PM</span>
      </div>
      <span className="visually-hidden" role="status">
        {hidden ? "Five menu bar icons are hidden." : touched ? "Five menu bar icons are showing." : ""}
      </span>
    </header>
  );
}
