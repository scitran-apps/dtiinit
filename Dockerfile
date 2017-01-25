# Create Flywheel Gear that can run dtiInit
# See https://github.com/vistalab/vistasoft/raw/97aa8a8/mrDiffusion/dtiInit/standalone for source code
#

FROM ubuntu:trusty
MAINTAINER Michael Perry <lmperry@stanford.edu>

# Install dependencies
RUN apt-get -qq update && apt-get -qq install -y \
    unzip \
    xorg \
    wget \
    curl \
    zip \
    gzip \
    python

# Download the MCR from Mathworks and silently install it
RUN mkdir /opt/mcr && \
    mkdir /mcr-install && \
    cd /mcr-install && \
    wget -nv http://www.mathworks.com/supportfiles/downloads/R2013b/deployment_files/R2013b/installers/glnxa64/MCR_R2013b_glnxa64_installer.zip && \
    unzip MCR_R2013b_glnxa64_installer.zip && \
    ./install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    cd / && \
    rm -rf /mcr-install

# ADD the dtiInit Matlab Stand-Alone (MSA) into the container.
ADD https://github.com/vistalab/vistasoft/raw/97aa8a8/mrDiffusion/dtiInit/standalone/executables/dtiInit_glnxa64_v82 /usr/local/bin/dtiInit

# Add bet2 (FSL) to the container
ADD https://github.com/vistalab/vistasoft/raw/97aa8a82/mrAnatomy/Segment/bet2 /usr/local/bin/

# Add the MNI_EPI template and JSON schema files to the container
ADD https://github.com/vistalab/vistasoft/raw/97aa8a82/mrDiffusion/templates/MNI_EPI.nii.gz /templates/
ADD https://github.com/vistalab/vistasoft/raw/97aa8a82/mrDiffusion/dtiInit/standalone/dtiInitStandAloneJsonSchema.json /templates/

# Copy the help text to display when no args are passed in.
COPY help.txt /opt/help.txt

# Ensure that the executable files are executable
RUN chmod +x /usr/local/bin/bet2 && chmod +x /usr/local/bin/dtiInit

# Configure environment variables for bet2
ENV FSLOUTPUTTYPE NIFTI_GZ

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}

# Copy and configure run script and metadata code
COPY run ${FLYWHEEL}/run
RUN chmod +x ${FLYWHEEL}/run
COPY manifest.json ${FLYWHEEL}/manifest.json
COPY parse_config.py ${FLYWHEEL}/parse_config.py
RUN chmod +x ${FLYWHEEL}/parse_config.py

# Configure entrypoint
ENTRYPOINT ["/flywheel/v0/run"]
