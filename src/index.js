const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;
const APP_VERSION = process.env.APP_VERSION || 'dev';
const STARTED_AT = Date.now();

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

let services = [
  {
    id: 1,
    name: 'User Auth Service',
    category: 'API',
    status: 'running',
    version: APP_VERSION,
    replicas: 3,
    uptime: 99.97,
    team: 'Platform',
    port: 8001,
    description: 'Handles authentication, JWT token issuance, and session management across all Ksolves products.',
    deployedAt: new Date(STARTED_AT - 86400000 * 5).toISOString(),
    tech: ['Node.js', 'Redis', 'PostgreSQL'],
  },
  {
    id: 2,
    name: 'Payment Gateway',
    category: 'API',
    status: 'running',
    version: APP_VERSION,
    replicas: 2,
    uptime: 99.99,
    team: 'Payments',
    port: 8002,
    description: 'Processes payment transactions via Stripe and Razorpay with PCI-DSS compliance.',
    deployedAt: new Date(STARTED_AT - 86400000 * 3).toISOString(),
    tech: ['Node.js', 'Stripe', 'Razorpay'],
  },
  {
    id: 3,
    name: 'Notification Engine',
    category: 'Worker',
    status: 'running',
    version: APP_VERSION,
    replicas: 2,
    uptime: 99.85,
    team: 'Platform',
    port: 8003,
    description: 'Sends email, SMS, and push notifications using a priority queue backed by Redis.',
    deployedAt: new Date(STARTED_AT - 86400000 * 2).toISOString(),
    tech: ['Node.js', 'Redis', 'SendGrid'],
  },
  {
    id: 4,
    name: 'AI Recommendation Engine',
    category: 'ML',
    status: 'running',
    version: APP_VERSION,
    replicas: 2,
    uptime: 99.90,
    team: 'AI Platform',
    port: 8004,
    description: 'Delivers real-time product and content recommendations using LLM embeddings and vector search.',
    deployedAt: new Date().toISOString(),
    tech: ['Python', 'FastAPI', 'Pinecone', 'OpenAI'],
  },
  {
  id: 5,
  name: 'Order Processing Service',
  category: 'API',
  status: 'running',
  version: APP_VERSION,
  replicas: 3,
  uptime: 99.94,
  team: 'Commerce',
  port: 8005,
  description: 'Manages end-to-end order lifecycle — creation, validation, fulfillment tracking, and payment confirmation for all Ksolves e-commerce clients.',
  deployedAt: new Date().toISOString(),
  tech: ['Node.js', 'Kafka', 'PostgreSQL'],
},
  {
    id: 6,
    name: 'Analytics & Reporting Service',
    category: 'Data',
    status: 'running',
    version: APP_VERSION,
    replicas: 2,
    uptime: 99.91,
    team: 'Data Platform',
    port: 8006,
    description: 'Aggregates real-time event streams into business dashboards, SLA reports, and anomaly alerts across all Ksolves platform services.',
    deployedAt: new Date().toISOString(),
    tech: ['Python', 'ClickHouse', 'Apache Flink', 'Grafana'],
  },
  {
    id: 7,
    name: 'Fraud Detection Engine',
    category: 'ML',
    status: 'running',
    version: APP_VERSION,
    replicas: 3,
    uptime: 99.96,
    team: 'Security',
    port: 8007,
    description: 'Real-time ML model scoring for transaction fraud detection using behavioral signals, device fingerprinting, and graph-based anomaly detection.',
    deployedAt: new Date().toISOString(),
    tech: ['Python', 'TensorFlow', 'Redis', 'Kafka'],
  },
];
let nextId = 8;

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', version: APP_VERSION, uptime: process.uptime() });
});

app.get('/api/services', (req, res) => {
  const { category } = req.query;
  const result = category ? services.filter(s => s.category === category) : services;
  res.json({ total: result.length, services: result });
});

app.get('/api/services/:id', (req, res) => {
  const svc = services.find(s => s.id === parseInt(req.params.id));
  if (!svc) return res.status(404).json({ error: 'Service not found' });
  res.json(svc);
});

app.get('/api/stats', (req, res) => {
  const running  = services.filter(s => s.status === 'running').length;
  const deploying = services.filter(s => s.status === 'deploying').length;
  const degraded  = services.filter(s => s.status === 'degraded').length;
  const teams     = [...new Set(services.map(s => s.team))].length;
  const totalReplicas = services.reduce((sum, s) => sum + s.replicas, 0);
  res.json({ total: services.length, running, deploying, degraded, teams, totalReplicas, version: APP_VERSION });
});

app.post('/api/services', (req, res) => {
  const { name, category, team, description, replicas, port } = req.body;
  if (!name) return res.status(400).json({ error: 'name is required' });
  const svc = {
    id: nextId++, name, category: category || 'API',
    status: 'running', version: APP_VERSION,
    replicas: replicas || 1, uptime: 100,
    team: team || 'Platform', port: port || 8000,
    description: description || '',
    deployedAt: new Date().toISOString(),
    tech: [],
  };
  services.push(svc);
  res.status(201).json(svc);
});

app.listen(PORT, () => console.log(`Ksolves SOC running on port ${PORT} — version ${APP_VERSION}`));
