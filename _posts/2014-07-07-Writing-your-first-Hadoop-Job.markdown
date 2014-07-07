--- 
layout: post
title: Writing your first Hadoop Job
date: 2014-07-07 11:16:46
authors: 
- usman
categories: 
- Big Data
tags:
- hadoop
permalink: /hadoopjob
---
{% image /assets/images/hadoop_elephant.png style="float:right" alt="Hadoop" class="pimage" height="221" width="310" %}
This article covers a very basic map reduce job which counts the occurrence of words in a document. The code for the job is adapted from the example which comes with Hadoop. This article is a follow up to an earlier article which walks through setting up a single node hadoop cluster. If you don't already have a running cluster please follow the steps in *[Setting up your first hadoop cluster](hadoopsetup)*. The source code that accompanies this article is available on github at [techtraits/hadoop-wordcount](https://github.com/techtraits/hadoop-wordcount).

# Project Setup

We will be using [Apache Maven](http://maven.apache.org/) to help write our hadoop job and the job will be written in Java. Hence if you have not done so already install a recent JDK version as well as maven. Once you have these tools create the maven pom.xml create a project element and add the groupId, artifactId and version for your project. We have used com.techtraits.hadoop as our group id and wordcount as out artifact id. 

{% codeblock  Maven Pom Project Element lang:xml %}
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.techtraits.hadoop</groupId>
	<artifactId>wordcount</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	
</project> 

{% endcodeblock %}

Next we add the build element within the project element and specify that we want to compile the source as Java 6 and also generate Java 6 byte code in our Jar file. 
{% codeblock  Maven Pom Build lang:xml %}
<build>
	<plugins>
		<plugin>
			<artifactId>maven-compiler-plugin</artifactId>
			<configuration>
				<source>1.6</source>
				<target>1.6</target>
			</configuration>
		</plugin>
	</plugins>
</build>
{% endcodeblock %}

We also add the dependencies element and include the hadoop dependency so that we will have access to the required library classes in our class path. The complete pom is should now look like [this](https://raw.githubusercontent.com/techtraits/hadoop-wordcount/master/pom.xml). 
{% codeblock  Maven Pom Dependencies lang:xml %}
<dependencies>
	<!-- Hadoop Dependencies -->
	<dependency>
		<groupId>org.apache.hadoop</groupId>
		<artifactId>hadoop-core</artifactId>
		<version>1.2.1</version>
	</dependency>
</dependencies>
{% endcodeblock %}


# Mapping and Reducing

Once we have our project setup lets write some code. The goal of our project is to create a simple MapReduce program can be written to determine how many times different words appear in a set of files. For example: if we had the files:

	foo.txt: This is the foo file
	bar.txt: This is the bar file

then the output would be:

	this  2
	is    2
	the   2
	foo   1
	bar   1
	file  2

To achieve this our map step involves tokening the file, traversing the words, and emitting a count of one for each word that is found. The code for this is shown below. We implement the Mapper interface's map method. When this method is called the value parameter of the method will contain a chunk of the file to be processed and the output parameter is used to emit word instances. This method will be run on many nodes in parallel with small chunks of the input file. Each node will collect its own counts and then send them to one of the reducers to combine the results. The complete Map class can be found [here](https://raw.githubusercontent.com/techtraits/hadoop-wordcount/master/src/main/java/com/techtraits/hadoop/wordcount/map/Map.java).

{% codeblock  Map Class lang:java %}
public class Map extends MapReduceBase implements Mapper<LongWritable, Text, Text, IntWritable> {
	
	private final static IntWritable one = new IntWritable(1);

	private Text word = new Text();

	public void map(LongWritable key, Text value,
			OutputCollector<Text, IntWritable> output, Reporter reporter)
			throws IOException {

		String line = value.toString();
		StringTokenizer tokenizer = new StringTokenizer(line);

		while (tokenizer.hasMoreTokens()) {
			word.set(tokenizer.nextToken());
			output.collect(word, one);
		}
	}
}
{% endcodeblock %}

Our reduce setup takes all the emitted word, count pairs and adds the counts together for each word. All counts for the same word will go to a single reducer node so that we get the final count for the word in one location. The code for the reducer is shown below; we implement the Reducer interface's reduce method. This method gets called with a Key which is the word and an iterator over the values which are the counts. We then re-emit the same word with the summation of its counts. Initially all the counts will be 1 as this is what our Mappers emit but the reduce step works iteratively. The outputs of a set of reduce invocations are again reduced and emitted until each key is reduced to a single value. The need for this repeated reduction arises because the various mappers will complete their tasks at different times and send their result to the reducer. The reducer does not have a complete picture at this point and therefore just summarizes the data it has so far and relies on subsequent reductions to complete the algorithm. The source for the Reduce class can be found [here](https://raw.githubusercontent.com/techtraits/hadoop-wordcount/master/src/main/java/com/techtraits/hadoop/wordcount/map/Reduce.java).

{% codeblock  Reduce Class lang:java %}
public class Reduce extends MapReduceBase implements
		Reducer<Text, IntWritable, Text, IntWritable> {

	public void reduce(Text key, Iterator<IntWritable> values,
			OutputCollector<Text, IntWritable> output, Reporter reporter)
			throws IOException {

		int sum = 0;
		while (values.hasNext()) {
			sum += values.next().get();
		}
		output.collect(key, new IntWritable(sum));
	}
}
{% endcodeblock %}

Now that we have the map and reduce steps available we need to complete our job by creating a 'Driver' class with a main function to setup up the job configuration and run the job. The code for this is shown below and complete class can be found [here](https://raw.githubusercontent.com/techtraits/hadoop-wordcount/master/src/main/java/com/techtraits/hadoop/wordcount/map/WordCount.java).

{% codeblock  Word Count Class lang:java %}
public class WordCount {
	public static void main(String[] args) throws Exception {
		JobConf conf = new JobConf(WordCount.class);
		conf.setJobName("wordcount");

		conf.setOutputKeyClass(Text.class);
		conf.setOutputValueClass(IntWritable.class);

		conf.setMapperClass(Map.class);
		conf.setCombinerClass(Reduce.class);
		conf.setReducerClass(Reduce.class);

		conf.setInputFormat(TextInputFormat.class);
		conf.setOutputFormat(TextOutputFormat.class);

		FileInputFormat.setInputPaths(conf, new Path(args[0]));
		FileOutputFormat.setOutputPath(conf, new Path(args[1]));

		JobClient.runJob(conf);

	}
}
{% endcodeblock %}

#Compiling the code

We can now build our code into a jar by running the mvn package command to generate the __WordCount-0.0.1-SNAPSHOT.jar__ file.

{% codeblock  Testing Hadoop Job lang:bash %}
mvn package
#....
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.212s
[INFO] Finished at: Mon Jul 07 13:21:52 EDT 2014
[INFO] Final Memory: 9M/104M
[INFO] ------------------------------------------------------------------------
ls target/WordCount-0.0.1-SNAPSHOT.jar
target/WordCount-0.0.1-SNAPSHOT.jar
{% endcodeblock %}	


# Testing your Hadoop Job
Run your hadoop container by running the the docker run command as described in *[Setting up your first hadoop cluster](hadoopsetup)*. Once in the container change to the hadoop directory defined in the HADOOP_PREFIX environment variable. We will then create two test files foo.txt and bar.txt and copy them into HDFS. We now need to get the jar file into the hadoop docker container, the easiest way to get the file into your container is to download it. You can upload your jar to dropbox, s3 or any other service and use curl to download it into the container. You can also download the jar that compiled from [http://techtraits.com.s3.amazonaws.com/assets/wordcount.jar](http://techtraits.com.s3.amazonaws.com/assets/wordcount.jar). We can then run the hadoop job using the jar command. You will see a lot of logs ending with Bytes written.

{% codeblock  Testing Hadoop Job lang:bash %}
# Run the hadoop docker container
docker run -p 50070:50070 -i -t sequenceiq/hadoop-docker /etc/bootstrap.sh -bash

# Change to hadoop directory in container
cd $HADOOP_PREFIX

# Create Director for input files in HDFS
bin/hdfs dfs -mkdir input/wordcount

# Create a test input file
echo "This is the foo file" > foo.txt

# Create another test input file
echo "This is the bar file" > bar.txt

# Copy files to HDFS
bin/hdfs dfs -copyFromLocal foo.txt input/wordcount/
bin/hdfs dfs -copyFromLocal bar.txt input/wordcount/

# Confirm files got copied
bin/hdfs dfs -ls input/wordcount
Found 2 items
-rw-r--r--   1 root supergroup         21 2014-07-06 21:40 input/wordcount/bar.txt
-rw-r--r--   1 root supergroup         21 2014-07-06 21:40 input/wordcount/foo.txt

# Get the Jar file
curl http://techtraits.com.s3.amazonaws.com/assets/wordcount.jar > wordcount.jar
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
101  5368  101  5368    0     0  23679      0 --:--:-- --:--:-- --:--:-- 67949

#Run the hadoop job
bin/hadoop jar wordcount.jar com.techtraits.hadoop.wordcount.WordCount input/wordcount/ output/wordcount/

#.....
File Input Format Counters
		Bytes Read=42
	File Output Format Counters
		Bytes Written=37
{% endcodeblock %}	

Now you can confirm the job was successful by checking the output folder in HDFS. Since this is a single node cluster there is only one part file with the results. If there were multiple nodes your would see more part files. You can cat the part file to see the word count result. There you have it, if you got this far you have run your first hadoop map-reduce job. You can now use this setup to experiment with writing more hadoop jobs. In future articles we will cover more complex jobs and using tools such as Flume to ingest larger data files to be processed. 

{% codeblock  Checking Output lang:bash %}
bin/hdfs dfs -ls output/wordcount
Found 2 items
-rw-r--r--   1 root supergroup          0 2014-07-06 22:03 output/wordcount/_SUCCESS
-rw-r--r--   1 root supergroup         37 2014-07-06 22:03 output/wordcount/part-00000

bin/hdfs dfs -cat output/wordcount/part-00000
This	2
bar	1
file	2
foo	1
is	2
the	2
{% endcodeblock %}	