# Create Flywheel Gear that can run dtiInit
# See https://github.com/vistalab/vistasoft/tree/master/mrDiffusion/dtiInit/standalone for source code

# Start with the Matlab r2013b runtime container
FROM vistalab/mcr-v82
MAINTAINER Michael Perry <lmperry@stanford.edu>

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
    zip \
    gzip \
    python

# ADD the dtiInit Matlab Stand-Alone (MSA) into the container.
ADD https://github.com/vistalab/vistasoft/raw/97aa8a83ea1e89a900e4c6597a404d84f7390b12/mrDiffusion/dtiInit/standalone/executables/dtiInit_glnxa64_v82 /usr/local/bin/dtiInit

# Add bet2 (FSL) to the container
ADD https://github.com/vistalab/vistasoft/raw/f1e7c57bb01bd281be6a8b93cc162994a1307b86/mrAnatomy/Segment/bet2 /usr/local/bin/

# Add the MNI_EPI template and JSON schema files to the container
ADD https://github.com/vistalab/vistasoft/raw/f1e7c57bb01bd281be6a8b93cc162994a1307b86/mrDiffusion/templates/MNI_EPI.nii.gz /templates/
ADD https://github.com/vistalab/vistasoft/raw/97aa8a83ea1e89a900e4c6597a404d84f7390b12/mrDiffusion/dtiInit/standalone/dtiInitStandAloneJsonSchema.json /templates/

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
ADD https://raw.githubusercontent.com/scitran/utilities/daf5ebc7dac6dde1941ca2a6588cb6033750e38c/metadata_from_gear_output.py ${FLYWHEEL}/metadata_create.py
RUN chmod +x ${FLYWHEEL}/metadata_create.py
COPY parse_config.py ${FLYWHEEL}/parse_config.py
RUN chmod +x ${FLYWHEEL}/parse_config.py

# Configure entrypoint
ENTRYPOINT ["/flywheel/v0/run"]
