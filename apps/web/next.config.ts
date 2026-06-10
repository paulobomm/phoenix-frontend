import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      {
        source: "/api/iam/:path*",
        destination: "http://localhost:5001/v1/:path*",
      },
      {
        source: "/api/projects/:path*",
        destination: "http://localhost:5002/v1/:path*",
      },
      {
        source: "/api/discovery/:path*",
        destination: "http://localhost:5003/v1/:path*",
      },
      {
        source: "/api/snapshots/:path*",
        destination: "http://localhost:5004/v1/:path*",
      },
      {
        source: "/api/restore/:path*",
        destination: "http://localhost:5005/v1/:path*",
      },
      {
        source: "/api/audit/:path*",
        destination: "http://localhost:5007/v1/:path*",
      },
      {
        source: "/api/admin-data/:path*",
        destination: "http://localhost:5006/v1/:path*",
      },
    ];
  },
};

export default nextConfig;
