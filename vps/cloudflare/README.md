# Cloudflare Tunnel — split setup

## Part 0 - Install Cloudflared

https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/local-management/create-local-tunnel/#1-download-and-install-cloudflared

## Part 1 — Install tunnel (one-time)
- Authenticates to Cloudflare, creates/reuses a tunnel, stores credentials here, writes `~/.clouflared/config.yml` with a default 404 rule.

## Part 2 — Add DNS tunnel route (repeatable)
- Run this any time to map a new hostname to a local service:
   ```bash
   chmod +x add_tunnel_dns.sh
   ./add_tunnel_dns.sh
   ```
   - Prompts for hostname and local service URL.
   - Updates `config.yml` ingress (idempotent) and creates the Cloudflare DNS route.

## Remove DNS route
- Remove a hostname mapping:
   ```bash
   chmod +x remove_tunnel_dns.sh
   ./remove_tunnel_dns.sh
   ```
   - Shows current hostnames and prompts for one to remove.
   - Updates `config.yml` and restarts tunnel (or stops if no hostnames remain).

## Part 3 — Auto-restart (one-time)
- Set up automatic tunnel restart to ensure it's always UP:
   ```bash
   chmod +x auto_restart_tunnel.sh
   ./auto_restart_tunnel.sh
   ```
   - Creates a systemd service that auto-starts on boot.
   - Automatically restarts the tunnel if it crashes or stops.
   - Simple and lightweight solution.

## Auto-restart commands
- Setup and start auto-restart: `./auto_restart_tunnel.sh`
- View service logs: `sudo journalctl -u cloudflare-tunnel-auto-restart -f`
- Service management: `sudo systemctl {start|stop|restart} cloudflare-tunnel-auto-restart`

## Notes:
- Re-run `add_tunnel_dns.sh` to add more hostnames/services.
- Restart the running tunnel after modifying `config.yml`.
- All configuration and credentials are stored in this directory.
- With auto-restart setup, the tunnel will automatically restart if it crashes.
- Service management: `sudo systemctl {start|stop|restart|status} cloudflare-tunnel-auto-restart`
