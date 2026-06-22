import { RouterProvider, createRouter } from "@tanstack/react-router";
import { routeTree } from "./routeTree.gen";

const router = createRouter({
  routeTree,
  defaultErrorComponent: ({ error }) => (
    <div className="min-h-screen flex flex-col items-center justify-center gap-4 p-8 bg-background text-foreground font-mono">
      <p className="text-primary text-xl font-bold">Something went wrong</p>
      <p className="text-sm text-muted-foreground">
        {error instanceof Error ? error.message : "Unknown error"}
      </p>
      <button
        data-ocid="error.go_home"
        type="button"
        onClick={() => window.location.replace("/")}
        className="mt-4 px-6 py-2 rounded-md bg-primary/15 border border-primary/40 text-primary text-sm cursor-pointer hover:bg-primary/25 transition-fast"
      >
        Go to Dashboard
      </button>
    </div>
  ),
  defaultNotFoundComponent: () => (
    <div className="min-h-screen flex flex-col items-center justify-center gap-3 p-8 bg-background text-foreground font-mono">
      <p className="text-primary text-lg font-bold">404 — Page not found</p>
      <button
        data-ocid="notfound.go_home"
        type="button"
        onClick={() => window.location.replace("/")}
        className="px-5 py-2 rounded-md bg-primary/12 border border-primary/35 text-primary text-sm cursor-pointer hover:bg-primary/20 transition-fast"
      >
        Go to Dashboard
      </button>
    </div>
  ),
});

declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}

export default function App() {
  return <RouterProvider router={router} />;
}
