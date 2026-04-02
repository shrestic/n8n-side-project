const uploadBtn = document.getElementById('uploadBtn');
const fileInput = document.getElementById('file');
const log = document.getElementById('log');

function append(msg) {
  log.textContent += msg + "\n";
}

uploadBtn.onclick = async () => {
  const file = fileInput.files[0];
  if (!file) return append("Choose a CSV file first.");
  append("Requesting presigned URL...");
  try {
    const qs = new URLSearchParams({ filename: file.name });
    // Replace this URL with your deployed presign endpoint
    const presignEndpoint = "/presign?" + qs.toString();
    const resp = await fetch(presignEndpoint);
    if (!resp.ok) throw new Error("Presign failed");
    const body = await resp.json();
    const uploadUrl = body.upload_url;
    append("Uploading file to S3...");
    const uploadResp = await fetch(uploadUrl, {
      method: "PUT",
      headers: { "Content-Type": "text/csv" },
      body: file
    });
    if (!uploadResp.ok) throw new Error("Upload failed: " + uploadResp.status);
    append("Upload complete. Waiting for pipeline...");
  } catch (e) {
    append("Error: " + e.message);
  }
};
