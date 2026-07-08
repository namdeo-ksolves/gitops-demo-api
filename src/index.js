const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// In-memory product store for demo
let products = [
  { id: 1, name: 'GitOps Toolkit', category: 'DevOps', price: 0 },
  { id: 2, name: 'ArgoCD', category: 'CD Tool', price: 0 },
  { id: 3, name: 'Helm Chart', category: 'Packaging', price: 0 },
  { id: 4, name: 'Kubernetes', category: 'Orchestration', price: 0 },
];
let nextId = 5;

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', version: process.env.APP_VERSION || '1.0.0', uptime: process.uptime() });
});

app.get('/', (req, res) => {
  res.json({ message: 'GitOps Demo API', version: process.env.APP_VERSION || '1.0.0' });
});

app.get('/api/products', (req, res) => {
  res.json({ total: products.length, products });
});

app.get('/api/products/:id', (req, res) => {
  const product = products.find(p => p.id === parseInt(req.params.id));
  if (!product) return res.status(404).json({ error: 'Product not found' });
  res.json(product);
});

app.post('/api/products', (req, res) => {
  const { name, category, price } = req.body;
  if (!name) return res.status(400).json({ error: 'name is required' });
  const product = { id: nextId++, name, category: category || 'General', price: price || 0 };
  products.push(product);
  res.status(201).json(product);
});

app.delete('/api/products/:id', (req, res) => {
  const idx = products.findIndex(p => p.id === parseInt(req.params.id));
  if (idx === -1) return res.status(404).json({ error: 'Product not found' });
  products.splice(idx, 1);
  res.json({ message: 'Deleted' });
});

app.listen(PORT, () => console.log(`GitOps Demo API running on port ${PORT}`));
