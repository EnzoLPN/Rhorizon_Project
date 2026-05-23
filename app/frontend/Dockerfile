FROM nginxinc/nginx-unprivileged:alpine

# Copy static assets to the Nginx HTML directory
COPY index.html style.css app.js /usr/share/nginx/html/

# Copy the custom Nginx server block configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
