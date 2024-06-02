#!/bin/sh
ls -la /opt/portfolio
cd /opt/portfolio/workspace
dbus-launch --exit-with-session openbox
exec /opt/portfolio/PortfolioPerformance
