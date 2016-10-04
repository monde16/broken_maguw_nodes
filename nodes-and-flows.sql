select count(1) from flow_uw; --56_841
select count(1) from flow_uw_node; --298_778
-- nodes with no exit
create view nodes_unended as
	select * from flow_uw_node
	where exit_ is null;
select count(1) from nodes_unended; --56_862
-- currently active nodes
create view nodes_active as
	select nodes.* from
	flow_uw_node nodes
	inner join flow_uw flows
	on nodes.uid=flows.node_uid;
select count(1) from nodes_active; --56_841
-- exit type nodes
create view nodes_exit_type as
	select * from flow_uw_node
	where node_type='ended';
select count(1) from nodes_exit_type; --53_518

create view nodes_valid_unended as
	select * from flow_uw_node
	where (
		uid in (select uid from nodes_active) or
		uid in (select uid from nodes_exit_type)
	);
select count(1) from nodes_valid_unended; --59_452

create view nodes_problematic as
	select nodes_unended.* from
	nodes_unended left outer join nodes_valid_unended
	on nodes_unended.uid=nodes_valid_unended.uid
	where nodes_valid_unended.uid is null;
select count(1) from nodes_problematic; --6			?????????????
-- done! Now fix them
create view flow_ids_with_problem_nodes as
	select distinct flow_uid from nodes_problematic;
select * from flow_ids_with_problem_nodes; -- print them

-- contains all nodes in each flow with at least 1 problem node
create view nodes_in_broken_flows as
	select nodes.* from
		flow_uw_node nodes inner join flow_ids_with_problem_nodes fids
		on nodes.flow_uid=fids.flow_uid
		order by flow_uid,last_modified_date desc;
select count(1) from nodes_in_broken_flows; -- 13
















select node_type,uid,created,assignee,due_date,exit_,exit_time,comment,reason,flow_uid,last_modified_date from nodes_problematic order by flow_uid, updated desc;
select * from flow_uw where node_uid in (select uid from nodes_problematic);
-- list all flows with problem node(s).
select distinct flow_uid from nodes_problematic;
-- show all nodes in each flow with at least 1 problem node
select * from flow_uw_node where flow_uid in (select distinct flow_uid from nodes_problematic) order by flow_uid, updated desc;
select node_type,uid,created,updated,assignee,exit_,exit_time,comment,reason,flow_uid,last_modified_date from flow_uw_node where flow_uid in (select distinct flow_uid from nodes_problematic) order by flow_uid, updated desc;
