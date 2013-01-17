DB DIFF
=====


What it does ?
---

DB DIFF will allow you to include in your build a way to check that you don't ommit to correctly migrate your datas.

Typical use case
---

We define our model your ORM (hibernate/jpa in my case) and have to migrate the datas between each version we produce.

How it works ?
---

* We ask to hbm2ddl to generate the sql script
* We have a sql script of a previous version : the first in production
* We have each script of each step (iteration) of our development that manage the evolution of the database
* When you run this process, a first schema is created with the full generated script (from scratch)
* A second schema is loaded incrementaly with each version
    - A good practice is to load some datas with it. Like this way, you can handle migration script with the updates of the model
    - If your migration doesn't work, the second schema could not be loaded
* A third schema is used to looking for differences with a view recreated each time
    - An anonymous procedure use this view to make a should be understandable output
