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

INSERT INTO widgets(title, panel_id) VALUES ('1A1', 1);
INSERT INTO widgets(title, panel_id) VALUES ('1A2', 1);
INSERT INTO widgets(title, panel_id) VALUES ('1A3', 1);

INSERT INTO widgets(title, panel_id) VALUES ('1B1', 2);
INSERT INTO widgets(title, panel_id) VALUES ('1B2', 2);
INSERT INTO widgets(title, panel_id) VALUES ('1B3', 2);

INSERT INTO widgets(title, panel_id) VALUES ('1C1', 3);
INSERT INTO widgets(title, panel_id) VALUES ('1C2', 3);

INSERT INTO widgets(title, panel_id) VALUES ('1D1', 4);

INSERT INTO dashboards (name) VALUES ('2'); 

INSERT INTO panels (title, dashboard_id) VALUES ('2A', 2);
INSERT INTO panels (title, dashboard_id) VALUES ('2B', 2);

INSERT INTO widgets(title, panel_id) VALUES ('2A1', 5);
INSERT INTO widgets(title, panel_id) VALUES ('2A2', 5);

INSERT INTO widgets(title, panel_id) VALUES ('2B1', 6);
INSERT INTO widgets(title, panel_id) VALUES ('2B2', 6);


SELECT dashboards.*, array_agg(panels.title)
FROM dashboards
JOIN panels
  ON panels.dashboard_id = dashboards.id
GROUP BY dashboards.id;


/* same as below */
SELECT dashboards.*, json_agg(panels) as "panels"
FROM dashboards
JOIN panels
  ON panels.dashboard_id = dashboards.id
GROUP BY (dashboards.id);

/* same as above */
/* get all the panels for each dashboard */
SELECT json_build_object('id',dashboards.id,'name',dashboards.name,'panels', array_to_json(array_agg(panels)))
FROM dashboards
JOIN panels
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
JOIN (
  SELECT panels.dashboard_id, json_build_object('id',panels.id,'title',panels.title,'dashboard_id',panels.dashboard_id,'widgets', array_to_json(array_agg(widgets))) panels_widgets
  FROM panels
  LEFT JOIN widgets
    ON widgets.panel_id = panels.id
  GROUP BY (panels.id)
  ) p
ON p.dashboard_id = dashboards.id
GROUP BY (dashboards.id);

/*
SELECT dashboards.*, array_to_json(array_agg(panels)) as "panels"
FROM dashboards
JOIN panels
  ON panels.dashboard_id = dashboards.id
JOIN (SELECT widgets.* FROM widgets WHERE widgets.panel_id = panel.id)
GROUP BY (dashboards.id);
*/


/*


select json_agg(sensor) 
from (
    select
        json_build_object('name', name, 'signatures', json_agg(signature)) sensor
    from sensors
    join (
        select 
            sensorid,
            json_build_object('signature', signature, 'firings:', json_agg(event)) signature
        from events e, 
        lateral row_to_json(e) event
        group by sensorid, signature
        ) s using(sensorid)
    group by sensorid
    ) s;


*/


SELECT dashboards.*, array_to_json(array_agg(panels)) as "panels" /*, array_to_json(array_agg(widgets)) as "widgets" */
FROM dashboards
JOIN panels
  ON dashboards.id = panels.dashboard_id

/* need subquery */
/*
JOIN widgets
  ON panels.id = widgets.panel_id  
*/
GROUP BY dashboard.id;

/* reuse panels and widgets with many-to-many tables */

CREATE TABLE dashboards {
  id SERIAL PRIMARY KEY,
  name TEXT  
};

CREATE TABLE dashboards_to_panels {
  id SERIAL PRIMARY KEY,       
  dashboard_id INTEGER NOT NULL,
  panel_id INTEGER NOT NULL,
  FOREIGN KEY (dashboard_id) REFERENCES dashboards (id),
  FOREIGN KEY (panel_id) REFERENCES panels (id)
};

CREATE TABLE panels {
  id SERIAL PRIMARY KEY,
  title TEXT
};

CREATE TABLE panels_to_widgets {
  id SERIAL PRIMARY KEY,       
  panel_id INTEGER NOT NULL,
  widget_id INTEGER NOT NULL,
  FOREIGN KEY (panel_id) REFERENCES panels (id),
  FOREIGN KEY (widget_id) REFERENCES widgets (id)
};

CREATE TABLE widgets {
  id SERIAL PRIMARY KEY,
  title TEXT
};
