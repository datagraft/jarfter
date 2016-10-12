FROM glassfish:4.0-jdk7

ENV PATH $PATH:/usr/local/bin/

# Download Leiningen
RUN wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && \
		chmod a+x lein && mv lein /usr/local/bin/lein && \
        lein  && \
        apt-get update && apt-get install -y maven

# Copy the files
COPY ./target/jarfter-1.0-SNAPSHOT.war /usr/local/var/jarfter.war
COPY ./src/main/resources/scripts/clj2*.sh /usr/local/bin/
COPY ./src/main/resources/jarfter-template /usr/local/var/jarfter-template/
COPY ./src/main/resources/warfter-template /usr/local/var/warfter_template
COPY ./src/main/resources/jarfter_config.json /usr/local/var/jarfter_config.json

# Compile jarfter-template and rename the standalone jar
WORKDIR /usr/local/var/jarfter-template/
RUN mvn deploy:deploy-file -Dfile=ww-geo-coords-1.0.jar -DgroupId=ww-geo-coords -DartifactId=ww-geo-coords -Dversion=1.0 -Dpackaging=jar -DlocalRepositoryPath=maven_repository -Durl=file:maven_repository && \
	mvn deploy:deploy-file -Dfile=geo-converter-0.0.1.jar -DgroupId=datagraft -DartifactId=geo-converter -Dversion=0.0.1 -Dpackaging=jar -DlocalRepositoryPath=maven_repository -Durl=file:maven_repository && \
		lein uberjar  && \
		cp /usr/local/var/jarfter-template/target/jarfter-0.1.0-SNAPSHOT-standalone.jar /usr/local/var/jarfter-template/jarfter.jar

# Deploy jarfter
WORKDIR /usr/local/glassfish4/bin/
RUN ./asadmin start-domain && \
	./asadmin deploy /usr/local/var/jarfter.war && \
	./asadmin stop-domain 
