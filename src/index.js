import { createServer } from "node:http";

const PORT = parseInt(process.env.PORT || "3001", 10);

const server = createServer((req, res) => {
  const userEmail =
    req.headers["cf-access-authenticated-user-email"] || "anonymous";

  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok" }));
    return;
  }

  console.log(
    JSON.stringify({
      app: "hello-world-three",
      user: userEmail,
      method: req.method,
      path: req.url,
    })
  );

  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(`<!DOCTYPE html>
<html>
<head><title>Hello World Three</title></head>
<body>
  <h1>Hello, ${userEmail}!</h1>
  <p>This is <strong>hello-world-three</strong> running on the Aseva LXC tier.</p>
</body>
</html>`);
});

server.listen(PORT, "127.0.0.1", () => {
  console.log(`hello-world-three listening on 127.0.0.1:${PORT}`);
});
