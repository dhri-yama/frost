import CopyCommand from "@/components/CopyCommand";
import MenuBar from "@/components/MenuBar";
import { asset, brewCommand, downloadUrl, releasesUrl, repoUrl, version } from "@/lib/site";

const sections = [
  { href: "#features", label: "On the menu" },
  { href: "#rules", label: "House rules" },
  { href: "#install", label: "Install" },
];

// The drinks-menu list: a name, a short note on the right, and a line under it. Plain descriptions of what Frost does.
const menu = [
  { name: "Hide the apps you choose", tag: "Or all but a few", text: "Pick apps one by one, or hide everything except your short list. Apps you open later stay hidden until you keep them." },
  { name: "Bring them back", tag: "One click", text: "The chevron shows them again, then tucks them away after a few seconds. You choose how long." },
  { name: "The panel", tag: "Optional", text: "Show hidden icons in a tidy panel under the menu bar instead. Click a tile to open that app." },
  { name: "Search every icon", tag: "⌃⌥Space", text: "Find any menu bar item, hidden or not. Type, arrow down, press Return." },
  { name: "Saved layouts", tag: "Work, Home, Presenting", text: "Save which apps are hidden and switch back to it with one click." },
  { name: "Presenting mode", tag: "⌃⌥P", text: "Keeps everything hidden while you share your screen." },
  { name: "Your own shortcuts", tag: "Click and press", text: "Record the keys you want for every action." },
  { name: "Four themes", tag: "Frost, Midnight, Mono, Paper", text: "Frost's own windows change. Your other apps' icons never do." },
];

// The honest limits. Each is a plain statement, and each matches the app's README.
const rules = [
  { rule: "It hides whole apps, not single icons.", text: "macOS 27 only lets an app's icons be hidden together." },
  { rule: "Focus and the camera light hide too.", text: "While Frost is hiding apps, macOS hides those two indicators as well." },
  { rule: "On macOS 27 it uses a private Apple API.", text: "If an update removes it, Frost tells you and falls back instead of failing quietly." },
  { rule: "Run it from Applications.", text: "macOS 27 only hides icons for apps that live in that folder." },
  { rule: "It isn't notarized yet.", text: "macOS asks you to choose Open Anyway the first time you open it." },
  { rule: "Accessibility is optional.", text: "Hiding works without it. You need it to search and to click a hidden icon for you." },
];

export default function Home() {
  return (
    <>
      <MenuBar links={sections} sourceUrl={repoUrl} />

      <main id="main">
        <section className="hero" id="top">
          <svg className="lamp" viewBox="0 0 190 440" aria-hidden="true" focusable="false">
            <defs>
              <linearGradient id="lamp-cone" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stopColor="#ffb35c" stopOpacity="0.26" />
                <stop offset="1" stopColor="#ffb35c" stopOpacity="0" />
              </linearGradient>
              <linearGradient id="lamp-shade" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stopColor="#2a1f14" />
                <stop offset="1" stopColor="#120d08" />
              </linearGradient>
              <radialGradient id="lamp-bulb">
                <stop offset="0" stopColor="#fff1d6" />
                <stop offset="0.4" stopColor="#ffb35c" />
                <stop offset="1" stopColor="#ffb35c" stopOpacity="0" />
              </radialGradient>
            </defs>
            <polygon className="lamp__cone" points="52,184 138,184 236,440 -46,440" fill="url(#lamp-cone)" />
            <line x1="95" y1="0" x2="95" y2="128" stroke="#3b3228" strokeWidth="1.5" />
            <path d="M32 184c0-36 28-56 63-56s63 20 63 56Z" fill="url(#lamp-shade)" stroke="#ffb35c" strokeOpacity="0.55" />
            <ellipse cx="95" cy="186" rx="26" ry="22" fill="url(#lamp-bulb)" />
          </svg>
          <div className="hero__sign" role="img" aria-label="Frost, in neon">
            <span className="neon" aria-hidden="true">Frost</span>
          </div>
          <h1 className="hero__title">Keep the clutter behind the bar.</h1>
          <p className="hero__lede">
            Frost hides the menu bar icons you don&rsquo;t need and brings them back with one click. Made for crowded menu
            bars, notched MacBooks, and macOS 27.
          </p>
          <div className="hero__actions">
            <a className="button" href={downloadUrl}>Download Frost {version}</a>
            <a className="textlink" href={repoUrl}>Read the source</a>
          </div>
          <p className="hero__hint">That&rsquo;s a working menu bar at the top of this page. Click its chevron.</p>
        </section>

        <section className="menu section" id="features" aria-labelledby="menu-title">
          <div className="menu__intro">
            <h2 className="section__title" id="menu-title">On the menu</h2>
            <p className="section__lede">Everything Frost does, and nothing it doesn&rsquo;t. Free, open source, and nothing leaves your Mac.</p>
          </div>
          <ul className="menu__list">
            {menu.map((m) => (
              <li key={m.name} className="menu__item">
                <div className="menu__row">
                  <h3 className="menu__name">{m.name}</h3>
                  <span className="menu__leader" aria-hidden="true" />
                  <span className="menu__tag">{m.tag}</span>
                </div>
                <p className="menu__text">{m.text}</p>
              </li>
            ))}
          </ul>
        </section>

        <section className="counter section" aria-labelledby="counter-title">
          <h2 className="section__title" id="counter-title">Behind the counter</h2>
          <div className="counter__grid">
            <figure className="shot shot--tall">
              <img src={asset("/images/general-frost.jpg")} alt="Frost's General settings in the default Frost theme" loading="lazy" width="1440" height="1200" />
              <figcaption>Settings, in the default Frost theme.</figcaption>
            </figure>
            <figure className="shot">
              <img src={asset("/images/layout-frost.jpg")} alt="The Layout pane listing hidden and visible apps, each with a Show or Hide button" loading="lazy" width="1440" height="1200" />
              <figcaption>Pick what hides, app by app.</figcaption>
            </figure>
            <figure className="shot">
              <img src={asset("/images/keys-frost.jpg")} alt="The Keys pane with a recordable shortcut for each action" loading="lazy" width="1440" height="1200" />
              <figcaption>Your shortcuts, your keys.</figcaption>
            </figure>
          </div>
          <div className="themes">
            <figure className="theme"><img src={asset("/images/general-midnight.jpg")} alt="The Midnight theme" loading="lazy" width="1440" height="1200" /><figcaption>Midnight</figcaption></figure>
            <figure className="theme"><img src={asset("/images/general-mono.jpg")} alt="The Mono theme" loading="lazy" width="1440" height="1200" /><figcaption>Mono</figcaption></figure>
            <figure className="theme"><img src={asset("/images/general-paper.jpg")} alt="The Paper theme" loading="lazy" width="1440" height="1200" /><figcaption>Paper</figcaption></figure>
          </div>
          <p className="counter__note">These are rendered by the app itself with sample data, so the real background blur isn&rsquo;t shown.</p>
        </section>

        <section className="rules section" id="rules" aria-labelledby="rules-title">
          <div className="board">
            <h2 className="section__title" id="rules-title">House rules</h2>
            <p className="section__lede">What Frost can&rsquo;t do, and what to know before you pour.</p>
            <ul className="board__list">
              {rules.map((r) => (
                <li key={r.rule} className="board__item">
                  <p className="board__rule">{r.rule}</p>
                  <p className="board__text">{r.text}</p>
                </li>
              ))}
            </ul>
          </div>
        </section>

        <section className="install section" id="install" aria-labelledby="install-title">
          <h2 className="section__title" id="install-title">Pull up a stool</h2>
          <ol className="steps">
            <li className="steps__item">
              <p className="steps__lead">Download the disk image and drag Frost to Applications.</p>
              <p className="steps__text"><a className="textlink" href={downloadUrl}>Frost-{version}.dmg</a> is about 2.4 MB. Works on macOS 13 or later; hiding works on macOS 27.</p>
            </li>
            <li className="steps__item">
              <p className="steps__lead">Open it from Applications.</p>
              <p className="steps__text">macOS will block it once. Open System Settings, then Privacy &amp; Security, and choose Open Anyway.</p>
            </li>
            <li className="steps__item">
              <p className="steps__lead">Follow the short setup.</p>
              <p className="steps__text">It explains each permission before it asks, and places the chevron for you.</p>
            </li>
          </ol>
          <div className="install__brew">
            <p className="install__label">Prefer Homebrew?</p>
            <CopyCommand command={brewCommand} />
          </div>
        </section>
      </main>

      <footer className="footer">
        <p className="footer__line">Closing time. Frost is open source under the MIT license, version {version}.</p>
        <nav className="footer__links" aria-label="Project links">
          <a className="textlink" href={repoUrl}>GitHub</a>
          <a className="textlink" href={releasesUrl}>Releases</a>
          <a className="textlink" href={`${repoUrl}/blob/main/CHANGELOG.md`}>Changelog</a>
          <a className="textlink" href={`${repoUrl}/blob/main/CREDITS.md`}>Credits</a>
        </nav>
        <p className="footer__small">Built on what the Ellipsis and Ice projects found out about the macOS menu bar.</p>
      </footer>
    </>
  );
}
