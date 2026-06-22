import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { Link, useLocation } from "@tanstack/react-router";
import {
  AlertTriangle,
  BookOpen,
  ChevronRight,
  Factory,
  FileText,
  Home,
  Menu,
  MessageSquare,
  Network,
  Settings,
  Shield,
  X,
} from "lucide-react";
import type { ReactNode } from "react";
import { useState } from "react";

const navItems = [
  { to: "/", label: "Home", icon: Home },
  { to: "/documents", label: "Documents", icon: FileText },
  { to: "/copilot", label: "Copilot", icon: MessageSquare },
  { to: "/graph", label: "Knowledge Graph", icon: Network },
  { to: "/rca", label: "Root Cause Analysis", icon: AlertTriangle },
  { to: "/compliance", label: "Compliance", icon: Shield },
  { to: "/lessons", label: "Lessons Learned", icon: BookOpen },
  { to: "/settings", label: "Settings", icon: Settings },
];

type LayoutProps = {
  children: ReactNode;
};

function SidebarContent() {
  const location = useLocation();
  return (
    <div className="flex flex-col h-full">
      <div className="p-4 border-b border-sidebar-border">
        <Link to="/" className="flex items-center gap-3 group">
          <div className="w-8 h-8 rounded-lg bg-primary/20 border border-primary/30 flex items-center justify-center">
            <Factory className="w-4 h-4 text-primary" />
          </div>
          <div>
            <span className="font-display font-semibold text-sm tracking-wide text-sidebar-foreground">
              INDUSMIND
            </span>
            <p className="text-[10px] text-sidebar-foreground/60 font-mono">
              AI Platform
            </p>
          </div>
        </Link>
      </div>
      <nav className="flex-1 p-3 space-y-1 overflow-auto">
        {navItems.map((item) => {
          const isActive = location.pathname === item.to;
          return (
            <Link
              key={item.to}
              to={item.to}
              data-ocid={`sidebar.nav.${item.label.toLowerCase().replace(/\s+/g, "_")}`}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-md text-sm transition-fast ${
                isActive
                  ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
                  : "text-sidebar-foreground/80 hover:bg-sidebar-accent/50 hover:text-sidebar-foreground"
              }`}
            >
              <item.icon className="w-4 h-4 shrink-0" />
              <span className="truncate">{item.label}</span>
              {isActive && (
                <ChevronRight className="w-3 h-3 ml-auto shrink-0" />
              )}
            </Link>
          );
        })}
      </nav>
      <div className="p-3 border-t border-sidebar-border">
        <p className="text-[10px] text-sidebar-foreground/40 text-center">
          © {new Date().getFullYear()}{" "}
          <a
            href={`https://caffeine.ai?utm_source=caffeine-footer&utm_medium=referral&utm_content=${encodeURIComponent(typeof window !== "undefined" ? window.location.hostname : "")}`}
            className="hover:text-sidebar-foreground/60 transition-fast"
            target="_blank"
            rel="noopener noreferrer"
          >
            caffeine.ai
          </a>
        </p>
      </div>
    </div>
  );
}

export function Layout({ children }: LayoutProps) {
  const [mobileOpen, setMobileOpen] = useState(false);

  return (
    <div className="min-h-screen flex bg-background text-foreground font-body">
      {/* Desktop sidebar */}
      <aside className="hidden md:flex w-64 shrink-0 flex-col bg-sidebar border-r border-sidebar-border">
        <SidebarContent />
      </aside>

      {/* Mobile sidebar drawer */}
      <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
        <SheetTrigger asChild>
          <Button
            data-ocid="sidebar.mobile_toggle"
            variant="ghost"
            size="icon"
            className="md:hidden fixed top-3 left-3 z-50"
          >
            <Menu className="w-5 h-5" />
          </Button>
        </SheetTrigger>
        <SheetContent
          side="left"
          className="w-64 p-0 bg-sidebar border-sidebar-border"
        >
          <SidebarContent />
        </SheetContent>
      </Sheet>

      {/* Main content */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Mobile header spacer */}
        <div className="md:hidden h-12 shrink-0" />
        <main className="flex-1 bg-background">{children}</main>
      </div>
    </div>
  );
}
