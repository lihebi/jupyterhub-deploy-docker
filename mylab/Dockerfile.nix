FROM nixlab

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ENV NB_USER="jovyan"
ENV NB_UID="1000"
ENV NB_GID="100"

# create user
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -m -s /bin/bash -G sudo -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd

WORKDIR /root
# Copy local files as late as possible to avoid cache busting
COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/


EXPOSE 8888

# ENTRYPOINT ["tini", "-g", "--"]
# CMD [ "/bin/jupyterhub-singleuser", "--ip=0.0.0.0", "--no-browser", "--allow-root", "--user=$JPY_USER", "--cookie-name=$JPY_COOKIE_NAME", "--base-url=$JPY_BASE_URL", "--hub-prefix=$JPY_HUB_PREFIX", "--hub-api-url=$JPY_HUB_API_URL"]
# CMD [ "/bin/jupyterhub-singleuser", "--ip=0.0.0.0", "--allow-root"]
  # CMD [ "/bin/jupyter-lab", "--ip=0.0.0.0", "--no-browser", "--allow-root"]

# FIXME the problem might be jupyterlab version problem, so try install
# jupyterlab and jupyterhub from conda

# CMD ["/opt/conda/bin/jupyterhub-singleuser", "--NotebookApp.default_url=/lab", "--SingleUserNotebookApp.default_url=/lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--notebook-dir=/root", "--debug"]


CMD ["/usr/local/bin/start-notebook.sh", "--allow-root"]
# CMD [ "/usr/local/bin/start-singleuser.sh", "--allow-root"]
