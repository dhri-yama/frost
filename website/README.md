# Frost website

The landing page for Frost: Next.js (App Router), exported as a static site. One theme, black: a bar at night, with a neon
sign and a lamp. The strip at the top of the page is a working menu bar; its chevron hides and shows the demo icons.

```sh
cd website
npm install
npm run dev      # http://localhost:3000
npm run build    # static site in out/
npm run lint
```

- **Version and download link** come from `../VERSION`, read at build time. Rebuild the site after cutting a release.
- **Type:** Big Shoulders (headings), Newsreader (text) and Sacramento (the neon logo only), self-hosted at build time by `next/font`.
- **Colour and layout** are plain CSS in `app/globals.css` (variables at the top). There is no CSS framework.
- **Images** in `public/images` are rendered by the app: run `Frost --snapshot <folder>` and copy the ones you want.
- **Motion:** the sign switches on once; the demo chevron collapses and expands the icons. Both respect `prefers-reduced-motion`.
- **Hosting:** `out/` is plain static files, so any static host works. For a sub-path such as GitHub Pages, build with
  `NEXT_PUBLIC_BASE_PATH=/frost npm run build`.
- **`public/_headers`** sets caching and security headers on Cloudflare Pages.

## Deploying to Cloudflare Pages
Set it up once in the dashboard under **Workers & Pages → Create → Pages → Import an existing Git repository**, choose
`dhri-yama/frost`, then fill in:

| Field | Value |
| --- | --- |
| Production branch | `main` |
| Framework preset | Next.js (Static HTML Export) |
| Build command | `npm run build` |
| Build output directory | `out` |
| Root directory (advanced) → Path | `website` |
| Environment variables | none needed |

Every push to `main` then rebuilds and deploys. `.node-version` (22) is read from the root directory; if a build picks the wrong
Node, set `NODE_VERSION` = `22`. `wrangler.jsonc` is the Workers (static assets) config, there for moving to Workers later; delete
it if a Pages build complains about it.
