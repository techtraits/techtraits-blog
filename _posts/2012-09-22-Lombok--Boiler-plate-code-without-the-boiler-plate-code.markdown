--- 
layout: post
title: "Lombok: Boiler-plate code without the boiler plate code"
date: 2012-09-22 04:42:18
authors: 
- usman
categories: 
- Programming
tags:
- Java
- Programming

---

I hate boiler-plate code, there I said it. It is not that I am too lazy to write code mindlessly- scratch that. It's not just that I am too lazy to write boiler plate code, boiler-plate code obfuscates the intent of the developer, it puts more lines of code that a reader has to go through to figure out what is actually going on and the more code you write the more-likely you are to introduce bugs. Having said that, boiler code is a necessary evil, right? Wrong. With [Lombok](http://projectlombok.org/) we get the benefits of boiler-plate code without having to deal wit it. It's nicely hidden away behind annotations.
<!--more-->
Before we start looking at Lombok code a word about eclipse code generation. While eclipse has a handy feature to generate a lot of boiler plate code for you which means there will be no bugs introduced and you don't have to write code yourself. However the eclipse generated code is still in your source hence any one reading the code still has to sift through some crud before finding the intent of the programmer. As we will see in Lombok we can reduce the visible code to only that which shows programmer intent. To whet your appetite and show the power of Lombok and annotations in general here is an actual source file from a rest service I am currently working on.

{% highlight java %}
import javax.persistence.Id;
import javax.persistence.Transient;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


@AllArgsConstructor(access = AccessLevel.PUBLIC)
@NoArgsConstructor
@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement
public @Data
class AccessToken {
    @Id
    private String userId;
    private String gameId;
    private String token;
    private String expires;

    @Transient
    private final List<GamePermission> scope = new ArrayList<GamePermission>();
}
{% endhighlight %}
&nbsp;

Notice the utter lack of any methods, not constructors, getters or setters. However, I have access to a whole slew of boiler-plate code as you can see from the eclipse outline view below.

![Eclipse Outline](/assets/images/eclipse_methods.png)

Below is exactly the same class now with all the boiler-plate code generated by eclipse. we go from about 20 lines of code to about 150. Which would you like to read and debug? Take another look at the long form code, notice anything funny? Look at the getter for gameId, I lied its not exactly the same class I added the toLowerCase method. This highlights the problem with boiler place code even if it is auto-generated. It could be that the toLowerCase is desired behaviour in this case. However, as some one reading the code you have an understandable predisposition to assume the getter for Game ID was just a plain old getter. However, unless you read every single getter you would not know that this one was different. With lombok the only explicitly defined getter (or any other method) will be the one that differs from the expectation. Hence you would not need to read any code just to confirm it is doing what you already assumed it would. Instead you would only see code that differentiates this getter from any other.

{% highlight java %}
import java.util.ArrayList;
import java.util.List;

import javax.persistence.Id;
import javax.persistence.Transient;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * This class is part of response to the getAccessToken and
 * getRefreshedAccessToken methods in class {@link AccessTokenResource
 * AccessTokenResource}
 * 
 * @author Usman Ismail
 * 
 */
@SuppressWarnings("PMD.UnusedPrivateField")
@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement
public class AccessToken {

    @Id
    private String userId;
    private String gameId;
    private String token;
    private String expires;

    @Transient
    private final List<GamePermission> scope = new ArrayList<GamePermission>();

    public AccessToken(String userId, String gameId, String token, String expires) {
    super();
    this.userId = userId;
    this.gameId = gameId;
    this.token = token;
    this.expires = expires;
    }

    @Override
    public String toString() {
    return "AccessToken [userId=" + userId + ", gameId=" + gameId + 
        ", token=" + token + ", expires=" + expires    + ", scope=" + scope + "]";
    }

    @Override
    public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((expires == null) ? 0 : expires.hashCode());
    result = prime * result + ((gameId == null) ? 0 : gameId.hashCode());
    result = prime * result + ((scope == null) ? 0 : scope.hashCode());
    result = prime * result + ((token == null) ? 0 : token.hashCode());
    result = prime * result + ((userId == null) ? 0 : userId.hashCode());
    return result;
    }

    @Override
    public boolean equals(Object obj) {
    if (this == obj)
        return true;
    if (obj == null)
        return false;
    if (getClass() != obj.getClass())
        return false;
    AccessToken other = (AccessToken) obj;
    if (expires == null) {
        if (other.expires != null)
        return false;
    } else if (!expires.equals(other.expires))
        return false;
    if (gameId == null) {
        if (other.gameId != null)
        return false;
    } else if (!gameId.equals(other.gameId))
        return false;
    if (scope == null) {
        if (other.scope != null)
        return false;
    } else if (!scope.equals(other.scope))
        return false;
    if (token == null) {
        if (other.token != null)
        return false;
    } else if (!token.equals(other.token))
        return false;
    if (userId == null) {
        if (other.userId != null)
        return false;
    } else if (!userId.equals(other.userId))
        return false;
    return true;
    }

    public String getUserId() {
    return userId;
    }

    public void setUserId(String userId) {
    this.userId = userId;
    }

    public String getGameId() {
    return gameId.toLowerCase();
    }

    public void setGameId(String gameId) {
    this.gameId = gameId;
    }

    public String getToken() {
    return token;
    }

    public void setToken(String token) {
    this.token = token;
    }

    public String getExpires() {
    return expires;
    }

    public void setExpires(String expires) {
    this.expires = expires;
    }

    public List<GamePermission> getScope() {
    return scope;
    }

}
{% endhighlight %}
&nbsp;



I will not go over all the features and annotations available in Lombok, the [project page](http://projectlombok.org/features/index.html) does a very good job. However, I do want to highlight how easy it is to integrate Lombok with your project. Just include the [Lombok Jar](http://projectlombok.googlecode.com/files/lombok.jar) in your class path. If you use maven use the dependency shown below. If you use eclipse lombok jar file and restart eclipse so that you can get code assists for the generated code.

<dependencies> 
    <dependency> 
        <groupId>org.projectlombok</groupId> 
        <artifactId>lombok</artifactId> 
        <version>0.11.4</version> 
        <scope>provided</scope> 
    </dependency>
</dependencies>

