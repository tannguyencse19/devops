# Active Context: Phase 1 - Cloudflare Domain Setup & DNS Configuration

## Current Phase
**Phase 1 of 5**: Cloudflare Domain Setup & DNS Configuration

## Objective
Configure Cloudflare DNS to route custom domain to VPS server with proper proxy settings.

## Progress Status
- [ ] Add domain to Cloudflare account
- [ ] Update nameservers at domain registrar  
- [ ] Verify Cloudflare shows "Active" status
- [ ] Configure DNS A records (apex, wildcard, coolify subdomain)
- [ ] Verify DNS propagation
- [ ] Configure Cloudflare proxy settings (SSL mode, security features)

## Key Information Needed
- **Domain name**: (to be provided by user)
- **VPS IP address**: (to be identified)
- **Current Coolify URL**: https://coolify.timothynguyen.work

## Required DNS Records
```
Type: A, Name: @, Value: <VPS_IP>, Proxy: ON (orange cloud)
Type: A, Name: *, Value: <VPS_IP>, Proxy: ON (orange cloud)  
Type: A, Name: coolify, Value: <VPS_IP>, Proxy: ON (orange cloud)
```

## Cloudflare Settings to Configure
- SSL/TLS Mode: Full (strict)
- Always Use HTTPS: ON
- WebSockets: ON
- HTTP/2, HTTP/3: ON
- HSTS: OFF (enable after testing)

## Next Steps After Phase 1
Move to Phase 2: SSL/TLS Certificate Configuration with Cloudflare API token setup.

## Notes
- Wait for DNS propagation between steps
- Test each DNS record before proceeding
- Keep current Coolify access until new domain is working