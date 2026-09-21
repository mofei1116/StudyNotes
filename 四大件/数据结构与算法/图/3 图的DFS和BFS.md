> 图的dfs和bfs与树的dfs和bfs思想相同，dfs用递归实现，bfs用队列实现，但为了避免图中的重复遍历，需要引入`visited`数组来标志顶点是否访问过

`visited`中每个顶点的下标与顶点在V集数组中的下标相同，每次遍历之前都要初始化为false

初始化visited：
```Cpp
void initVisited(bool* visited,MGraph* graph){
	memset(visited,0,sizeof(bool)*graph->vertexNum);
}
```

> 邻接矩阵和邻接表的遍历思路都基本相同，只是==找邻接点的方式==不一样

# DFS

每次访问顶点后把visited数组中顶点对应的单元==更改为ture==，然后**递归**地遍历该节点地所有==未访问过==（在visited中标志为false）的==邻接点==

> 假设是**连通图**或**强连通图**

- 邻接矩阵：找v的邻接点时遍历v在矩阵中的所有出度，即==遍历第v行==
	```Cpp
	void dfs(MGraph* graph,int v){    //传入一个起点
		visit(v);    //访问行为
		visited[v]=true;
		for(int i=0;i<graph->vertexNum;i++){    //找未访问过邻接点
			if(graph->V[v][i]!=0&&graph->V[v][i]!=INFI&&visited[i]==false){
				dfs(graph,i);
			}
		}
	}
	```

- 邻接表：找v的邻接点时直接遍历节点v的==出度链表==
	```Cpp
	void dfs(LGraph* graph,int v){
		visit(v);    //访问行为
		visited[v]=ture;
		Edge* p=graph->V[v].firstEdge;
		while(p){    //找未访问过的邻接点
			if(visited[p->id]==false){
				dfs(graph,p->id);
			}
			p=p->next;
		}
	}
	```

# BFS

每次访问队首顶点后把visited数组中顶点对应的单元==更改为ture==，然后出队，并把v节点的所有==未访问过==的==邻接点==入队，重复下一次循环

> 假设是**连通图**或**强连通图**

- 邻接矩阵
	```Cpp
	void bfs(MGraph* graph,int x){    //从x开始
		queue<int> q;    //队列
		q.push(x);    //先把起点入队
		while(!q.empty()){
			int v=q.front();
			q.pop();
			visit(v);    //访问行为
			visited[v]=true;
			for(int i=0;i<graph->vertexNum;i++){    //找未访问过邻接点
				if(graph->V[v][i]!=0&&graph->V[v][i]!=INFI&&visited[i]==false){
					q.push(i);
				}
			}
		}
	}
	```

- 邻接表
	```Cpp
	void bfs(LGraph* graph,int x){    //从x开始
		queue<int> q;    //队列
		q.push(x);    //先把起点入队
		while(!q.empty()){
			int v=q.front();
			q.pop();
			visit(v);    //访问行为
			visited[v]=true;
			Edge* p=graph->V[v].firstEdge;
			while(p){    //找未访问过的邻接点
				if(visited[p->id]==false){
					q.push(p->id);
				}
				p=p->next;
			}
		}
	}
	```

# 非连通图或非强连通图的遍历

需要在遍历外面套一层循环，对图中每个visited不为true的节点遍历

```Cpp
void traversal(MGraph* graph){    //邻接表同理
	for(int i=0;i<graph->vectorNum;i++){
		if(visited[i]==false){
			dfs(graph,i);    //bfs同理
		}
	}
}
```