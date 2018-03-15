/* reuse panels and widgets with many-to-many tables */
CREATE DATABASE reusable_dashboard;

CREATE TABLE dashboards (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE panels (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL
);

CREATE TABLE dashboards_to_panels (
  id SERIAL PRIMARY KEY,       
  dashboard_id INTEGER NOT NULL,
  panel_id INTEGER NOT NULL,
  FOREIGN KEY (dashboard_id) REFERENCES dashboards (id),
  FOREIGN KEY (panel_id) REFERENCES panels (id)
);

CREATE TABLE widgets (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL
);

CREATE TABLE panels_to_widgets (
  id SERIAL PRIMARY KEY,       
  panel_id INTEGER NOT NULL,
  widget_id INTEGER NOT NULL,
  FOREIGN KEY (panel_id) REFERENCES panels (id),
  FOREIGN KEY (widget_id) REFERENCES widgets (id)
);

/*
DROP TABLE dashboards;
DROP TABLE panels;
DROP TABLE dashboards_to_panels;
DROP TABLE widgets;
DROP TABLE panels_to_widgets;
*/

INSERT INTO dashboards (name) VALUES ('1'); 

INSERT INTO panels (title) VALUES ('1A');
INSERT INTO panels (title) VALUES ('1B');
INSERT INTO panels (title) VALUES ('1C');
INSERT INTO panels (title) VALUES ('1D');

INSERT INTO dashboards_to_panels (dashboard_id, panel_id) VALUES (1,1);
INSERT INTO dashboards_to_panels (dashboard_id, panel_id) VALUES (1,2);
INSERT INTO dashboards_to_panels (dashboard_id, panel_id) VALUES (1,3);
INSERT INTO dashboards_to_panels (dashboard_id, panel_id) VALUES (1,4);

INSERT INTO widgets (title) VALUES ('1A1');
INSERT INTO widgets (title) VALUES ('1A2');
INSERT INTO widgets (title) VALUES ('1A3');

INSERT INTO widgets (title) VALUES ('1B1');
INSERT INTO widgets (title) VALUES ('1B2');
INSERT INTO widgets (title) VALUES ('1B3');

INSERT INTO widgets (title) VALUES ('1C1');
INSERT INTO widgets (title) VALUES ('1C2');

INSERT INTO widgets (title) VALUES ('1D1');

INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (1,1);
INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (1,2);
INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (1,3);

INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (2,4);
INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (2,5);
INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (2,5);

INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (3,7);
INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (3,8);

INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (4,9);

INSERT INTO dashboards (name) VALUES ('2'); 

INSERT INTO panels (title) VALUES ('2A');
INSERT INTO panels (title) VALUES ('2B');

INSERT INTO dashboards_to_panels (dashboard_id, panel_id) VALUES (2,5);
INSERT INTO dashboards_to_panels (dashboard_id, panel_id) VALUES (2,6);

INSERT INTO widgets (title) VALUES ('2A1');
INSERT INTO widgets (title) VALUES ('2A2');

INSERT INTO widgets (title) VALUES ('2B1');
INSERT INTO widgets (title) VALUES ('2B2');

INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (5,10);
INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (5,11);

INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (6,12);
INSERT INTO panels_to_widgets (panel_id, widget_id) VALUES (6,13);

/* no widgets in panels */
INSERT INTO dashboards (name) VALUES ('3'); 

INSERT INTO panels (title) VALUES ('3A');
INSERT INTO panels (title) VALUES ('3B');

INSERT INTO dashboards_to_panels (dashboard_id, panel_id) VALUES (3,7);
INSERT INTO dashboards_to_panels (dashboard_id, panel_id) VALUES (3,8);

/* no panels in dashboards */
INSERT INTO dashboards (name) VALUES ('4'); 

/* get all the panels for each dashboard */
SELECT json_build_object('id',dashboards.id,'name',dashboards.name,'panels', array_to_json(array_agg(panels)))
FROM dashboards
LEFT JOIN dashboards_to_panels
  ON dashboards_to_panels.dashboard_id = dashboards.id 
LEFT JOIN panels
  ON panels.id = dashboards_to_panels.panel_id
GROUP BY (dashboards.id);

/* get all the widgets for each panel */
SELECT json_build_object('id',panels.id,'title',panels.title,'widgets', array_to_json(array_agg(widgets)))
FROM panels
LEFT JOIN panels_to_widgets
  ON panels_to_widgets.panel_id = panels.id
LEFT JOIN widgets
  ON panels_to_widgets.widget_id = widgets.id
GROUP BY (panels.id);

/* get all the widgets for each panel, get each panel for each dashboard */
SELECT json_build_object('id',dashboards.id,'name',dashboards.name,'panels', array_to_json(array_agg(panels_widgets)))
FROM dashboards
LEFT JOIN dashboards_to_panels
  ON dashboards_to_panels.dashboard_id = dashboards.id 
LEFT JOIN (
  SELECT panels.id, json_build_object('id',panels.id,'title',panels.title,'widgets', array_to_json(array_agg(widgets))) panels_widgets
  FROM panels
  LEFT JOIN panels_to_widgets
    ON panels_to_widgets.panel_id = panels.id
  LEFT JOIN widgets
    ON panels_to_widgets.widget_id = widgets.id
  GROUP BY (panels.id)
  ) p
ON p.id = dashboards_to_panels.panel_id
GROUP BY (dashboards.id);
