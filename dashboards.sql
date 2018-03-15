/* M-x new-frame, C-x 5 o (switch frames), C-x 5 0 delete current frame */
CREATE DATABASE dashboard;

/* direct ownership */
CREATE TABLE dashboards (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE panels (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  dashboard_id INTEGER NOT NULL,
  FOREIGN KEY (dashboard_id) REFERENCES dashboards (id)
);

CREATE TABLE widgets (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  panel_id INTEGER NOT NULL,
  FOREIGN KEY (panel_id) REFERENCES panels (id)
);

INSERT INTO dashboards (name) VALUES ('1'); 

INSERT INTO panels (title, dashboard_id) VALUES ('1A', 1);
INSERT INTO panels (title, dashboard_id) VALUES ('1B', 1);
INSERT INTO panels (title, dashboard_id) VALUES ('1C', 1);
INSERT INTO panels (title, dashboard_id) VALUES ('1D', 1);

INSERT INTO widgets (title, panel_id) VALUES ('1A1', 1);
INSERT INTO widgets (title, panel_id) VALUES ('1A2', 1);
INSERT INTO widgets (title, panel_id) VALUES ('1A3', 1);

INSERT INTO widgets (title, panel_id) VALUES ('1B1', 2);
INSERT INTO widgets (title, panel_id) VALUES ('1B2', 2);
INSERT INTO widgets (title, panel_id) VALUES ('1B3', 2);

INSERT INTO widgets (title, panel_id) VALUES ('1C1', 3);
INSERT INTO widgets (title, panel_id) VALUES ('1C2', 3);

INSERT INTO widgets (title, panel_id) VALUES ('1D1', 4);

INSERT INTO dashboards (name) VALUES ('2'); 

INSERT INTO panels (title, dashboard_id) VALUES ('2A', 2);
INSERT INTO panels (title, dashboard_id) VALUES ('2B', 2);

INSERT INTO widgets (title, panel_id) VALUES ('2A1', 5);
INSERT INTO widgets (title, panel_id) VALUES ('2A2', 5);

INSERT INTO widgets (title, panel_id) VALUES ('2B1', 6);
INSERT INTO widgets (title, panel_id) VALUES ('2B2', 6);

/* no widgets in panels */
INSERT INTO dashboards (name) VALUES ('3'); 

INSERT INTO panels (title, dashboard_id) VALUES ('3A', 3);
INSERT INTO panels (title, dashboard_id) VALUES ('3B', 3);

/* no panels in dashboards */
INSERT INTO dashboards (name) VALUES ('4'); 

/* json_agg() = array_to_json(array_agg()) */
/* get all the panels for each dashboard */
SELECT json_build_object('id',dashboards.id,'name',dashboards.name,'panels', array_to_json(array_agg(panels)))
FROM dashboards
LEFT JOIN panels
  ON panels.dashboard_id = dashboards.id
GROUP BY (dashboards.id);

/* get all the widgets for each panel */
SELECT json_build_object('id',panels.id,'title',panels.title,'widgets', array_to_json(array_agg(widgets)))
FROM panels
LEFT JOIN widgets
  ON widgets.panel_id = panels.id
GROUP BY (panels.id);

/* get all the widgets for each panel, get each panel for each dashboard */
SELECT json_build_object('id',dashboards.id,'name',dashboards.name,'panels', array_to_json(array_agg(panels_widgets)))
FROM dashboards
LEFT JOIN (
  SELECT panels.dashboard_id, json_build_object('id',panels.id,'title',panels.title,'dashboard_id',panels.dashboard_id,'widgets', array_to_json(array_agg(widgets))) panels_widgets
  FROM panels
  LEFT JOIN widgets
    ON widgets.panel_id = panels.id
  GROUP BY (panels.id)
  ) p
ON p.dashboard_id = dashboards.id
GROUP BY (dashboards.id);
