---
layout: post
title: Impact of Docker and Rancher on Network Performance
date: 2016-02-23 10:51:43
authors:
- usman
categories:
- System Admin
tags:
- docker
- network
permalink: /dockerperf.html
---
One of the concerns that is expressed with using Docker in production is the impact on network performance. In today's article we present the results of our study of network performance on Ec2 platform. We compare the performance between: stock AWS Linux AMI, docker with ports exposed, Rancher's overlay network and the recently released Swarm overlay network.

Before we get into the test results I would like to quickly cover our testing setup. For the network throughput tests we will be using iperf 3.0.1 running on AWS C4.XLarge instances. We are using those instances as they provide a "high" level of network I/O and are sufficiently provisioned with CPU and memory that factors other than network performance should not interfere with test results.

## Test Scenarios

As mentioned we compare four network scenarios, for a base line we ran iperf tests directly between two Amazon instances.

{% image /assets/images/docker_net_sc1.png alt="Scenario 1" class="pimage" %}

Next, we installed docker on the same instances and brought up the iperf Server on one of the hosts inside a docker container. Note the container image we use can be found on docker hub at [techtraits/iperf:3.0.1](https://hub.docker.com/r/techtraits/iperf/). While running the container we expose 2105, iperf's default port, on both TCP and UDP protocols using the -P switch so that it is addressable on the host network. This will use docker's bridged networking and provides our second test scenario. Note for completeness we also run the iperf client in a docker container on its own amazon host.

{% image /assets/images/docker_net_sc2.png alt="Scenario 2" class="pimage" %}

For the third test scenario we ran a Rancher Server and two Rancher Compute nodes (each on their own amazon instance). We launched the iperf docker container as a iperf server on one of the compute nodes and as the client on the other. In this scenario we used Rancher's built in Overlay networking capabilities to allow the nodes to communicate. This involves routing traffic through two Network Agent helper containers running on each of the AWS instances. The Agents maintain IP Sec VPN tunnels between each other to route traffic between containers.

{% image /assets/images/docker_net_sc3.png alt="Scenario 3" class="pimage" %}

For our final scenario we setup a Swarm cluster using Consl for service discover. We launch the Consl instance and Swarm Master on their own AWS instances to make sure their processing workload does not impact our results and also to more closely resemble a production deployment. We create an overlay network using the new network driver support to allow our iPerf client and server to communicate.

{% image /assets/images/swarm-setup.png alt="Scenario 4" class="pimage" %}

## TCP  Results

The first set of tests we ran for each of our four scenario were to measure the maximum TCP throughput. We open fifty concurrent TCP streams from the iperf client to the server, let them each run for 120 seconds. We discard the first 60s to account let the system get into a steady state and then measured the total throughput of the steams averaged across the remaining 60 seconds.  We than ran this entire experiment 10 times in order to get greater confidence that our results were repeatable. The aggregate throughput in our four scenarios is shown below with the 95% confidence intervals. As you can see using stock docker has a negligible impact on through put reducing the value from 745 Mb/s to 739 Mb/s. This is not statistically significant as it is within the margin of error.

{% image /assets/images/docker-net-tcp.png alt="TCP Results" class="pimage" width="450" height="340" %}

Even when using Rancher's overlay network there was statistically significant but fairly minor drop in throughput to 708 Mb/s. We note that none of the AWS instances seemed to be under CPU or Memory pressure during the test hence the likely culprits are inefficiencies in the rancher overlay networking driver. However, when using Swarms overlay network driver we see a large hit on network performance. Our throughput is reduced to ~400 Mb/s which is a hit of almost 45%. We do not see memory or CPU pressure on these instance and again suspect driver issues as the cause of the performance hit.


## UDP  Results

To measure the performance of UDP protocol we send packets at a fix rate and then measure the percentage which they are lost on route. When then increase the transmission rate and see how to loss rate grows with transmission rate. Note the experiment is repeated ten times for each transmission rate to make sure we get representative results.

{% image /assets/images/docker-net-udp-aws.png alt="TCP Results" class="pimage" width="500" height="340" %}

Our baseline test with AWS Instances without docker was able to sustain a transmission rate of 700 Mb/s without any loss rate. At 768 Mb/s we saw a 2% loss rate and beyond that point we saw large loss rates reaching ~20% at 896 Mb/s. Using Docker's bridge networking to expose a port on the host we see a small loss rate even at very low transmission rates. At approximately 400 Mb/s we start to see loss rates higher than 1%. Then we see loss rates plateau until we reach ~700 Mb/s at which point we again start to see loss rates increase dramatically.

{% image /assets/images/docker-net-udp-overlay.png alt="TCP Results" class="pimage" width="500" height="340" %}

The UDP protocol results for the Rancher Overlay network is a lot more drastic. We were only able to sustain transmission rates of 12Mb/s without seeing loss rates. Beyond these rates we quickly see loss rates climb to significantly high rates. For the Swarm overlay network the sustained throughput without loss is is around 10Mb/s. Beyond this we see error rates increase rapidly.


## Conclusions

From our testing we can conclude that Docker bridge networking and even Rancher's overlay networks do not cause a significant overhead for long running TCP connections. This is relevant to Databases and Caches as they often use long-running connections between their clients and servers with a large throughout requirements. From our testing this workload should not pose problems for Docker or Rancher.

For UDP networking which may be used in many real-time workloads we see consistently higher loss rates when using docker but the problems only become more pronounced when we are pushing our underlying network beyond 50% of its capacity or more. However, when using overlay networks such as Swarm and Rancher we see that we are only able to sustain low transmission rates (under 10-12Mbp/s). Based on these results using Docker for real-time workloads seems problematic even when using bridge networking and the performance of Rancher's overlay network more or less precludes their use for UDP traffic. This is not entirely unexpected as Rancher uses VPN to encrypt traffic, VPN connection establishment is an expensive process and having to setup and tear down the connection for each UDP packet will cause problems. If you do run a UDP based network workload on Docker and Rancher it may be best to use host networking for now.

## Caveats

Although we made efforts to make sure the tests are as representative as possible there are certain caveats to these results. Firstly, network tests are always point-in-time tests and network characteristics tend to be ephemeral. We have tried our best to keep the test instances as identical as possible however we cannot control or isolate the performance of the underlying network.

Second, the absolute values we presented are specific to AWS C4.Xlarge instances running in US East and should not be taken as absolute limits or guarantees of performance in different platforms.

Third, We used fairly well provisioned AWS instances to run our tests, this ensured that CPU and memory resources were not impacting results. However, in real world scenarios you may be running workloads which utilize more of the systems resources. Since some of the test cases use software defined network stacks the performance is sensitive to processing resources.

Lastly, one thing missing in our testing is short-lived TCP connections. This scenario is very common in services for example REST servers generally deal with many short lived connections. We hope to cover such traffic in detail in a subsequent article.
