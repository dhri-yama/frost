import type { NextConfig } from "next";

// Static export: the site is plain HTML/CSS/JS in `out/`, hostable anywhere.
// Set NEXT_PUBLIC_BASE_PATH (e.g. "/frost") when serving from a sub-path such as GitHub Pages.
const basePath = process.env.NEXT_PUBLIC_BASE_PATH || undefined;

const nextConfig: NextConfig = {
  output: "export",
  basePath,
  images: { unoptimized: true },
};

export default nextConfig;
