# Cloudflare Tunnel — split setup

All files and config live in this folder.

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

## Notes:
- Re-run `add_tunnel_dns.sh` to add more hostnames/services.
- Restart the running tunnel after modifying `config.yml`.
- All configuration and credentials are stored in this directory.
- With auto-restart setup, the tunnel will automatically restart if it crashes.
- Service management: `sudo systemctl {start|stop|restart|status} cloudflare-tunnel-auto-restart`
