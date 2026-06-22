import { ExternalBlob } from "@/backend";
import { Layout } from "@/components/Layout";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import {
  useDeleteDocument,
  useDocuments,
  useUploadDocument,
} from "@/hooks/useQueries";
import { createFileRoute } from "@tanstack/react-router";
import { FileText, Filter, Search, Upload } from "lucide-react";
import { useRef, useState } from "react";

export const Route = createFileRoute("/documents")({
  component: DocumentsPage,
});

function DocumentsPage() {
  const { data: documents, isLoading } = useDocuments();
  const uploadMutation = useUploadDocument();
  const deleteMutation = useDeleteDocument();
  const [searchQuery, setSearchQuery] = useState("");
  const fileInputRef = useRef<HTMLInputElement>(null);

  const filteredDocs = documents
    ? documents.filter((d) =>
        d.filename.toLowerCase().includes(searchQuery.toLowerCase()),
      )
    : [];

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    try {
      const arrayBuffer = await file.arrayBuffer();
      const bytes = new Uint8Array(arrayBuffer);
      const blob = ExternalBlob.fromBytes(bytes);
      await uploadMutation.mutateAsync({
        filename: file.name,
        mimeType: file.type || "application/octet-stream",
        blob,
        fileSize: BigInt(file.size),
      });
    } catch {
      // error handled by mutation state
    }
    if (fileInputRef.current) fileInputRef.current.value = "";
  };

  const handleDelete = async (id: bigint) => {
    if (!confirm("Delete this document?")) return;
    await deleteMutation.mutateAsync(id);
  };

  const statusBadge = (status: string) => {
    const variant =
      status === "ready" || status === "processed" || status === "extracted"
        ? "default"
        : status === "error"
          ? "destructive"
          : "secondary";
    return <Badge variant={variant}>{status}</Badge>;
  };

  return (
    <Layout>
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-display font-semibold text-foreground">
              Document Center
            </h1>
            <p className="text-sm text-muted-foreground mt-1">
              Universal document ingestion and management
            </p>
          </div>
          <div>
            <input
              ref={fileInputRef}
              type="file"
              className="hidden"
              onChange={handleFileChange}
              accept=".pdf,.docx,.xlsx,.csv,.png,.jpg,.jpeg"
            />
            <Button
              data-ocid="documents.upload_button"
              className="gap-2"
              onClick={() => fileInputRef.current?.click()}
              disabled={uploadMutation.isPending}
            >
              <Upload className="w-4 h-4" />
              {uploadMutation.isPending ? "Uploading..." : "Upload Documents"}
            </Button>
          </div>
        </div>

        {uploadMutation.isError && (
          <div className="p-3 rounded-md bg-destructive/10 text-destructive text-sm">
            Upload failed. Please try again.
          </div>
        )}

        <div className="flex items-center gap-3">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <input
              data-ocid="documents.search_input"
              type="text"
              placeholder="Search documents..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full h-10 pl-9 pr-4 rounded-md border border-input bg-background text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
            />
          </div>
          <Button variant="outline" className="gap-2">
            <Filter className="w-4 h-4" />
            Filter
          </Button>
        </div>

        {isLoading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {Array.from({ length: 8 }).map(() => (
              <Card
                key="doc-skeleton"
                className="hover:border-primary/40 transition-smooth"
              >
                <CardHeader className="pb-3">
                  <Skeleton className="h-5 w-5" />
                </CardHeader>
                <CardContent className="space-y-2">
                  <Skeleton className="h-5 w-32" />
                  <Skeleton className="h-4 w-20" />
                </CardContent>
              </Card>
            ))}
          </div>
        ) : filteredDocs.length === 0 ? (
          <div className="p-12 text-center text-muted-foreground text-sm">
            {searchQuery
              ? "No documents match your search."
              : "No documents uploaded yet."}
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {filteredDocs.map((doc, i) => (
              <Card
                key={doc.id.toString()}
                data-ocid={`documents.item.${i + 1}`}
                className="hover:border-primary/40 transition-smooth cursor-pointer"
              >
                <CardHeader className="pb-3">
                  <div className="flex items-center justify-between">
                    <FileText className="w-5 h-5 text-primary" />
                    {statusBadge(doc.status)}
                  </div>
                </CardHeader>
                <CardContent>
                  <CardTitle className="text-base truncate">
                    {doc.filename}
                  </CardTitle>
                  <p className="text-sm text-muted-foreground mt-1">
                    {doc.mimeType}
                  </p>
                  <p className="text-xs text-muted-foreground mt-1">
                    {new Date(
                      Number(doc.createdAt) * 1000,
                    ).toLocaleDateString()}
                  </p>
                  <button
                    data-ocid={`documents.delete_button.${i + 1}`}
                    type="button"
                    onClick={() => handleDelete(doc.id)}
                    className="mt-3 text-xs text-destructive hover:underline"
                  >
                    Delete
                  </button>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </Layout>
  );
}
