<%=     from = "FROM #{@image}"
        platform = case @platform
        when 'debian', 'ubuntu'
          disable_upstart = <<-eos
            RUN dpkg-divert --local --rename --add /sbin/initctl
            RUN ln -sf /bin/true /sbin/initctl
          eos
          packages = <<-eos
            ENV DEBIAN_FRONTEND noninteractive
            RUN apt-get update
            RUN apt-get install -y sudo openssh-server curl lsb-release
          eos
          @disable_upstart ? disable_upstart + packages : packages
        when 'rhel', 'centos', 'fedora'
          <<-eos
            RUN yum clean all
            RUN yum install -y sudo openssh-server openssh-clients which curl
            RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
            RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''
          eos
        when 'arch'
          <<-eos
            RUN pacman -Syu --noconfirm
            RUN pacman -S --noconfirm openssh sudo curl
            RUN ssh-keygen -A -t rsa -f /etc/ssh/ssh_host_rsa_key
            RUN ssh-keygen -A -t dsa -f /etc/ssh/ssh_host_dsa_key
          eos
        when 'gentoo'
          <<-eos
            RUN emerge sync
            RUN emerge net-misc/openssh app-admin/sudo
            RUN ssh-keygen -A -t rsa -f /etc/ssh/ssh_host_rsa_key
            RUN ssh-keygen -A -t dsa -f /etc/ssh/ssh_host_dsa_key
          eos
        when 'gentoo-paludis'
          <<-eos
            RUN cave sync
            RUN cave resolve -zx net-misc/openssh app-admin/sudo
            RUN ssh-keygen -A -t rsa -f /etc/ssh/ssh_host_rsa_key
            RUN ssh-keygen -A -t dsa -f /etc/ssh/ssh_host_dsa_key
          eos
        else
          raise ActionFailed,
          "Unknown platform '#{@platform}'"
        end

        username = @username
        password = @password
        public_key = IO.read(@public_key).strip
        homedir = username == 'root' ? '/root' : "/home/#{username}"

        base = <<-eos
          RUN if ! getent passwd #{username}; then \
                useradd -d #{homedir} -m -s /bin/bash #{username}; \
              fi
          RUN echo #{username}:#{password} | chpasswd
          RUN echo '#{username} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
          RUN mkdir -p /etc/sudoers.d
          RUN echo '#{username} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/#{username}
          RUN chmod 0440 /etc/sudoers.d/#{username}
          RUN mkdir -p #{homedir}/.ssh
          RUN chown -R #{username} #{homedir}/.ssh
          RUN chmod 0700 #{homedir}/.ssh
          RUN touch #{homedir}/.ssh/authorized_keys
          RUN chown #{username} #{homedir}/.ssh/authorized_keys
          RUN chmod 0600 #{homedir}/.ssh/authorized_keys
        eos
        custom = ''
        Array(@provision_command).each do |cmd|
          custom << "RUN #{cmd}\n"
        end
        ssh_key = "RUN echo '#{public_key}' >> #{homedir}/.ssh/authorized_keys"
        # Empty string to ensure the file ends with a newline.
        [from, platform, base, custom, ssh_key, ''].join("\n")
%>

RUN yum install -y git which

RUN mkdir -p /tmp/kitchen-platform
WORKDIR /tmp/kitchen-platform

# follow cloud_conductor_init
RUN echo 'git clone https://github.com/cloudconductor/cloud_conductor_init.git /opt/cloudconductor' > ./bootstrap.sh && \
    echo 'cd /opt/cloudconductor' >> ./bootstrap.sh

# RUN echo 'git checkout develop' >> ./bootstrap.sh
RUN echo 'git checkout feature/support-centos7' >> ./bootstrap.sh

# follow prepare.sh from pattern
RUN echo 'git clone https://github.com/cloudconductor-patterns/<%= @cc_pattern %>.git /opt/cloudconductor/patterns/<%= @cc_pattern %>' > ./bootstrap.sh && \
    echo 'cd /opt/cloudconductor/patterns/<%= @cc_pattern %>' >> ./bootstrap.sh

#RUN echo 'git checkout develop' >> ./bootstrap.sh
RUN echo 'git checkout feature/support-centos7' >> ./bootstrap.sh

RUN echo 'git pull' >> ./bootstrap.sh && \
    echo 'export PATTERN_NAME="<%= @cc_pattern %>"' >> ./bootstrap.sh && \
    echo 'bash -x ./bin/setup.sh' >> ./bootstrap.sh

RUN echo 'git pull' >> ./bootstrap.sh && \
    echo 'bash -x prepare.sh' >> ./bootstrap.sh

RUN bash -x ./bootstrap.sh

# support proxy
<% if @http_proxy || @https_proxy %>
RUN echo "export no_proxy=172.0.0.1,localhost" > /etc/profile.d/proxy.sh
<% if @http_proxy %>
RUN echo "export http_proxy=<%= @http_proxy %>" >> /etc/profile.d/proxy.sh
<% end %>
<% if @https_proxy %>
RUN echo "export https_proxy=<%= @http_proxy %>" >> /etc/profile.d/proxy.sh
<% end %>
<% end %>
