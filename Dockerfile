FROM ubuntu:24.04

ARG NVIM_VERSION=v0.11.3

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       bash \
       ca-certificates \
       curl \
       git \
       lua5.1 \
       sqlite3 \
       xz-utils \
  && rm -rf /var/lib/apt/lists/* \
  && curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
       | tar -xz -C /opt \
  && ln -s "/opt/nvim-linux-x86_64/bin/nvim" /usr/local/bin/nvim

# These dependencies are needed by the plugin when it is loaded in Neovim.
RUN git clone --depth 1 --branch 0.1.8 \
      https://github.com/nvim-telescope/telescope.nvim /opt/telescope.nvim \
  && git clone --depth 1 \
      https://github.com/nvim-lua/plenary.nvim /opt/plenary.nvim \
  && git clone --depth 1 \
      https://github.com/kkharji/sqlite.lua /opt/sqlite.lua \
  && git clone --depth 1 \
      https://github.com/nvim-treesitter/nvim-treesitter /opt/nvim-treesitter \
  && git clone --depth 1 \
      https://github.com/neovim/nvim-lspconfig /opt/nvim-lspconfig

COPY docker/nvim/init.lua /opt/zotero-nvim-init.lua

WORKDIR /plugin
COPY . .

CMD ["bash"]
