import React, { useState, useEffect } from "react";
import "./App.css";

interface SecurityMetric {
  name: string;
  value: number;
  status: "good" | "warning" | "critical";
  description: string;
}

const App: React.FC = () => {
  const [metrics, setMetrics] = useState<SecurityMetric[]>([]);
  const [currentTime, setCurrentTime] = useState<string>("");

  useEffect(() => {
    // Simulate security metrics
    const mockMetrics: SecurityMetric[] = [
      {
        name: "Failed Login Attempts",
        value: 3,
        status: "good",
        description: "Login attempts blocked in last hour",
      },
      {
        name: "SSL Certificates Expiring",
        value: 2,
        status: "warning",
        description: "Certificates expiring within 30 days",
      },
      {
        name: "Open Security Vulnerabilities",
        value: 0,
        status: "good",
        description: "Critical vulnerabilities requiring attention",
      },
      {
        name: "Firewall Rules Updated",
        value: 24,
        status: "good",
        description: "Hours since last firewall rule update",
      },
    ];

    setMetrics(mockMetrics);

    // Update time every second
    const timer = setInterval(() => {
      setCurrentTime(new Date().toLocaleString());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  const getStatusColor = (status: string): string => {
    switch (status) {
      case "good":
        return "#10B981";
      case "warning":
        return "#F59E0B";
      case "critical":
        return "#EF4444";
      default:
        return "#6B7280";
    }
  };

  const getStatusIcon = (status: string): string => {
    switch (status) {
      case "good":
        return "✅";
      case "warning":
        return "⚠️";
      case "critical":
        return "🚨";
      default:
        return "⚪";
    }
  };

  return (
    <div className='App'>
      <header className='App-header'>
        <h1>🛡️ Security Operations Dashboard</h1>
        <p className='subtitle'>Real-time Security Monitoring</p>
        <p className='timestamp'>Last Updated: {currentTime}</p>
      </header>

      <main className='dashboard'>
        <div className='metrics-grid'>
          {metrics.map((metric, index) => (
            <div key={index} className='metric-card'>
              <div className='metric-header'>
                <span className='metric-icon'>
                  {getStatusIcon(metric.status)}
                </span>
                <h3>{metric.name}</h3>
              </div>
              <div
                className='metric-value'
                style={{ color: getStatusColor(metric.status) }}>
                {metric.value}
              </div>
              <p className='metric-description'>{metric.description}</p>
            </div>
          ))}
        </div>

        <div className='info-section'>
          <h2>📊 Security Status Overview</h2>
          <div className='status-summary'>
            <div className='status-item'>
              <span className='status-dot good'></span>
              <span>Systems Operating Normally</span>
            </div>
            <div className='status-item'>
              <span className='status-dot warning'></span>
              <span>2 Items Require Attention</span>
            </div>
            <div className='status-item'>
              <span className='status-dot critical'></span>
              <span>No Critical Issues</span>
            </div>
          </div>
        </div>

        <div className='deployment-info'>
          <h3>🚀 Deployment Information</h3>
          <p>
            <strong>Platform:</strong> AWS S3 + CloudFront
          </p>
          <p>
            <strong>Security:</strong> HTTPS with SSL/TLS
          </p>
          <p>
            <strong>Built by:</strong> Raymond Nwambuonwo
          </p>
          <p>
            <strong>Project:</strong> Operation Jump Ship - Static Website
            Deployment
          </p>
        </div>
      </main>
    </div>
  );
};

export default App;
