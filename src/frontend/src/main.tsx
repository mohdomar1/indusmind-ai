import { InternetIdentityProvider } from "@caffeineai/core-infrastructure";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Component, type ErrorInfo, type ReactNode } from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";

BigInt.prototype.toJSON = function () {
  return this.toString();
};

// Ensure dark mode is always active — belt-and-suspenders
document.documentElement.classList.add("dark");
document.documentElement.style.colorScheme = "dark";
document.body.style.backgroundColor = "oklch(0.145 0 0)";
document.body.style.color = "oklch(0.92 0 0)";

declare global {
  interface BigInt {
    toJSON(): string;
  }
}

// ── Top-level error boundary so a provider crash never shows a blank screen ──

type ErrorBoundaryState = { hasError: boolean; error: Error | null };

class RootErrorBoundary extends Component<
  { children: ReactNode },
  ErrorBoundaryState
> {
  constructor(props: { children: ReactNode }) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error("[RootErrorBoundary] Caught:", error, info);
  }

  render() {
    if (this.state.hasError) {
      // Render the app shell even if providers fail — game is playable without auth
      return <App />;
    }
    return this.props.children;
  }
}

// ── Safe II provider — catches synchronous or render-time errors ──

class SafeIIProvider extends Component<
  { children: ReactNode },
  { failed: boolean }
> {
  constructor(props: { children: ReactNode }) {
    super(props);
    this.state = { failed: false };
  }

  static getDerivedStateFromError(): { failed: boolean } {
    return { failed: true };
  }

  componentDidCatch(error: Error) {
    console.warn(
      "[SafeIIProvider] InternetIdentityProvider failed:",
      error.message,
    );
  }

  render() {
    if (this.state.failed) {
      return this.props.children;
    }
    return (
      <InternetIdentityProvider>{this.props.children}</InternetIdentityProvider>
    );
  }
}

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

ReactDOM.createRoot(document.getElementById("root")!).render(
  <RootErrorBoundary>
    <QueryClientProvider client={queryClient}>
      <SafeIIProvider>
        <App />
      </SafeIIProvider>
    </QueryClientProvider>
  </RootErrorBoundary>,
);
