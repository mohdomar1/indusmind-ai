import type { MessageRole } from "@/backend";
import { Layout } from "@/components/Layout";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import {
  useChatMessages,
  useChatThreads,
  useCreateChatThread,
  useSendMessage,
} from "@/hooks/useQueries";
import { createFileRoute } from "@tanstack/react-router";
import { Bot, FileText, Send, TrendingUp, User } from "lucide-react";
import { useEffect, useRef, useState } from "react";

export const Route = createFileRoute("/copilot")({
  component: CopilotPage,
});

const suggestions = [
  "Why does Boiler B-12 repeatedly fail?",
  "Show compliance gaps for Factory Act 1948",
  "List all safety incidents in Q2 2024",
  "What lessons learned relate to overheating?",
];

function CopilotPage() {
  const [input, setInput] = useState("");
  const [activeThreadId, setActiveThreadId] = useState<bigint | null>(null);
  const { data: threads, isLoading: threadsLoading } = useChatThreads();
  const { data: messages, isLoading: messagesLoading } =
    useChatMessages(activeThreadId);
  const createThread = useCreateChatThread();
  const sendMessage = useSendMessage();
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, []);

  const handleNewThread = async () => {
    const thread = await createThread.mutateAsync("New Conversation");
    setActiveThreadId(thread.id);
  };

  const handleSend = async () => {
    if (!input.trim()) return;
    let threadId = activeThreadId;
    if (!threadId) {
      const thread = await createThread.mutateAsync(input.slice(0, 50));
      threadId = thread.id;
      setActiveThreadId(threadId);
    }
    await sendMessage.mutateAsync({
      threadId,
      role: "user" as unknown as MessageRole,
      content: input,
      sources: [],
      confidence: null,
    });
    setInput("");
  };

  const allMessages = messages || [];

  return (
    <Layout>
      <div className="flex flex-col h-[calc(100vh-4rem)]">
        <div className="p-6 border-b border-border flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-display font-semibold text-foreground">
              Expert Knowledge Copilot
            </h1>
            <p className="text-sm text-muted-foreground mt-1">
              RAG-based expert assistant with source citations
            </p>
          </div>
          <Button
            data-ocid="copilot.new_thread_button"
            variant="outline"
            className="gap-2"
            onClick={handleNewThread}
            disabled={createThread.isPending}
          >
            <Bot className="w-4 h-4" />
            New Chat
          </Button>
        </div>

        <div className="flex flex-1 overflow-hidden">
          {/* Thread sidebar */}
          <div className="w-64 border-r border-border hidden lg:flex flex-col bg-card/30">
            <div className="p-3 border-b border-border">
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
                Conversations
              </p>
            </div>
            <div className="flex-1 overflow-auto p-2 space-y-1">
              {threadsLoading ? (
                Array.from({ length: 3 }).map((_, i) => (
                  // biome-ignore lint/suspicious/noArrayIndexKey: skeleton placeholders have no stable id
                  <Skeleton key={`thr-skel-${i}`} className="h-10 w-full" />
                ))
              ) : threads && threads.length > 0 ? (
                threads.map((thread) => (
                  <button
                    key={thread.id.toString()}
                    type="button"
                    onClick={() => setActiveThreadId(thread.id)}
                    className={`w-full text-left px-3 py-2 rounded-md text-sm transition-fast ${
                      activeThreadId === thread.id
                        ? "bg-primary/10 text-primary font-medium"
                        : "text-muted-foreground hover:bg-muted/50"
                    }`}
                  >
                    <p className="truncate">{thread.title}</p>
                    <p className="text-[10px] text-muted-foreground/60">
                      {new Date(
                        Number(thread.updatedAt) * 1000,
                      ).toLocaleDateString()}
                    </p>
                  </button>
                ))
              ) : (
                <p className="text-xs text-muted-foreground p-3">
                  No conversations yet
                </p>
              )}
            </div>
          </div>

          {/* Messages area */}
          <div className="flex-1 flex flex-col min-w-0">
            <div className="flex-1 overflow-auto p-6 space-y-4">
              {messagesLoading ? (
                Array.from({ length: 3 }).map((_, i) => (
                  // biome-ignore lint/suspicious/noArrayIndexKey: skeleton placeholders have no stable id
                  <div key={`msg-skel-${i}`} className="flex gap-3">
                    <Skeleton className="h-8 w-8 rounded-full shrink-0" />
                    <Skeleton className="h-20 w-3/4" />
                  </div>
                ))
              ) : allMessages.length === 0 ? (
                <div className="h-full flex flex-col items-center justify-center text-muted-foreground">
                  <Bot className="w-12 h-12 mb-4 opacity-40" />
                  <p className="text-sm">
                    Start a conversation or select a thread
                  </p>
                </div>
              ) : (
                allMessages.map((msg, i) => (
                  <div
                    key={msg.id.toString()}
                    data-ocid={`copilot.message.${i + 1}`}
                    className={`flex gap-3 ${msg.role === "user" ? "justify-end" : ""}`}
                  >
                    {msg.role === "assistant" && (
                      <div className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center shrink-0">
                        <Bot className="w-4 h-4 text-primary" />
                      </div>
                    )}
                    <Card
                      className={`max-w-2xl ${
                        msg.role === "user"
                          ? "bg-primary/10 border-primary/20"
                          : "bg-card"
                      }`}
                    >
                      <CardContent className="p-4">
                        <p className="text-sm whitespace-pre-wrap">
                          {msg.content}
                        </p>
                        {msg.role === "assistant" &&
                          msg.sources &&
                          msg.sources.length > 0 && (
                            <div className="mt-3 pt-3 border-t border-border/50 flex items-center gap-3">
                              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                <FileText className="w-3 h-3" />
                                {msg.sources.length} sources
                              </div>
                              {msg.confidence !== undefined &&
                                msg.confidence !== null && (
                                  <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                    <TrendingUp className="w-3 h-3" />
                                    {msg.confidence}% confidence
                                  </div>
                                )}
                            </div>
                          )}
                      </CardContent>
                    </Card>
                    {msg.role === "user" && (
                      <div className="w-8 h-8 rounded-full bg-accent/20 flex items-center justify-center shrink-0">
                        <User className="w-4 h-4 text-accent" />
                      </div>
                    )}
                  </div>
                ))
              )}
              <div ref={messagesEndRef} />
            </div>

            <div className="p-4 border-t border-border bg-card/50">
              <div className="flex flex-wrap gap-2 mb-3">
                {suggestions.map((s, i) => (
                  <Badge
                    key={s}
                    data-ocid={`copilot.suggestion.${i + 1}`}
                    variant="secondary"
                    className="cursor-pointer hover:bg-primary/20 transition-fast"
                    onClick={() => {
                      setInput(s);
                    }}
                  >
                    {s}
                  </Badge>
                ))}
              </div>
              <div className="flex gap-2">
                <input
                  data-ocid="copilot.input"
                  type="text"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && handleSend()}
                  placeholder="Ask anything about your industrial knowledge base..."
                  className="flex-1 h-10 px-4 rounded-md border border-input bg-background text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
                />
                <Button
                  data-ocid="copilot.send_button"
                  onClick={handleSend}
                  className="gap-2"
                  disabled={sendMessage.isPending || !input.trim()}
                >
                  <Send className="w-4 h-4" />
                  {sendMessage.isPending ? "Sending..." : "Send"}
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}
