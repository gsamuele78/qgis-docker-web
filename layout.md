```
qgis-docker/
├── data/
│   └── storage/  # Your persistent QGIS data directory
├── nginx/
│   └── nginx.conf # Nginx configuration file
├── filebrowser/
│   └── database.db # File Browser database (optional, can be a volume)
├── certbot/        # Directory for certbot configurations
│   ├── duckdns.ini # DuckDNS credentials
│   └── duckdns.sh # DuckDNS hook script
├── xpra/
│   └── xpra.conf   # Xpra configuration file
├── scripts/
│   ├── setup.sh      # Setup script
│   └── join-domain.sh # Domain join script
├── docker-compose.yml
├── Dockerfile
├── start-xpra.sh
├── .env
├── .gitignore
├── LICENSE
└── README.md
└── log/ # Centralized log directory
    ├── qgis.log
    ├── nginx.log
    └── filebrowser.log
```
