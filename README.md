DB DIFF
=====


What it does ?
---

DB DIFF will allow you to include in your build a way to check that you don't ommit to correctly migrate your datas.

Typical use case
---

We define our model with an ORM (hibernate/jpa in my case) and have to migrate the datas between each version we produce.

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

Declaration of schemas
---

```sql
create user from_diff identified by from_diff;
grant connect,resource to from_diff;
create user from_scratch identified by from_scratch;
grant connect,resource to from_scratch;
create user diff identified by diff;
grant connect,resource,create view,select any table to diff;
```

The diff user need to have access to from_diff and from_v schemas.
It's even a bad idea to use it on a sharable instance because of the way you can use it.
Oracle is not designed to create drop all the time the objects, so for our case, you can experience pretty long run.

How to improve it
---

* First step : make a maven plugin of this, the pom is indead quite long and verbose.

So some tasks could be automated :

* merge the update scripts together
* check that only the last script is modified (we have an other unit test for that, that we change on each end iteration)
* generate the create_from_scratch script
* don't be oracle dependant : use jsbc implementation to compute differences but it could point others problems

Conclusion
===

If you have any comment, feel free to open an issue, make a pull request ... to share with everybody.
