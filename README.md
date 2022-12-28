# Toon Shader for Unity
This is based on [Toon Shader tutorial](https://roystan.net/articles/toon-shader.html) from the site [roystan.net](https://roystan.net/).

![alt text](https://i.imgur.com/0PbpWYg.png)

Has specular, rim lighting, and can cast and receive shadows.

## Differences with base project

* Add Forward-Addtional Lights.
* Add Ndc-based Outline.
![image](https://user-images.githubusercontent.com/25216715/209772374-4968c608-779a-4fb8-8cbb-68d0c19d00a0.png)


## Compared with Built-in Standard Shader
![image](https://user-images.githubusercontent.com/25216715/209773008-e7015e33-b9cd-41b1-a06b-1584cb36d6cf.png)
![image](https://user-images.githubusercontent.com/25216715/209772880-31e39853-ad64-42bd-b1d1-1d35ad449d82.png)

## Defect to solve

* Objects with hard edges cause outline-gaps.

![image](https://user-images.githubusercontent.com/25216715/209773691-9cfd7d76-28ee-4be8-80e2-ed43085c387e.png)

Maybe need some tricks to get smoothed normals.
