// Turns every H2/H3 section into a collapsible block.
// Add { .collapsed } after a heading in Markdown to start that section closed.
(function () {
  var STATE_KEY = "collapsibleReady";

  function setState(heading, body, collapsed) {
    body.hidden = collapsed;
    heading.classList.toggle("is-collapsed", collapsed);
    heading.setAttribute("aria-expanded", String(!collapsed));
  }

  function makeCollapsible(root) {
    var nodes = Array.prototype.slice.call(root.children);
    var sections = [];

    nodes.forEach(function (heading, index) {
      if (!/^H[23]$/.test(heading.tagName) || heading.dataset[STATE_KEY]) {
        return;
      }

      var level = Number(heading.tagName.charAt(1));
      var collected = [];

      for (var i = index + 1; i < nodes.length; i++) {
        var next = nodes[i];
        if (/^H[1-6]$/.test(next.tagName) && Number(next.tagName.charAt(1)) <= level) {
          break;
        }
        collected.push(next);
      }

      if (!collected.length) {
        return;
      }

      var body = document.createElement("div");
      body.className = "collapsible-body";
      heading.after(body);
      collected.forEach(function (node) {
        body.appendChild(node);
      });

      var marker = document.createElement("span");
      marker.className = "collapsible-marker";
      heading.insertBefore(marker, heading.firstChild);

      heading.dataset[STATE_KEY] = "1";
      heading.classList.add("collapsible-heading");
      heading.setAttribute("role", "button");
      heading.setAttribute("tabindex", "0");
      setState(heading, body, heading.classList.contains("collapsed"));

      heading.addEventListener("click", function (event) {
        if (event.target.closest("a")) {
          return;
        }
        setState(heading, body, !body.hidden);
      });

      heading.addEventListener("keydown", function (event) {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          setState(heading, body, !body.hidden);
        }
      });

      sections.push({ heading: heading, body: body });
    });

    return sections;
  }

  function makeControls(sections) {
    var bar = document.createElement("div");
    bar.className = "collapsible-controls";
    bar.setAttribute("role", "group");
    bar.setAttribute("aria-label", "Section controls");

    [["Expand all", false], ["Collapse all", true]].forEach(function (item) {
      var button = document.createElement("button");
      button.type = "button";
      button.className = "collapsible-control";
      button.textContent = item[0];
      button.addEventListener("click", function () {
        sections.forEach(function (section) {
          setState(section.heading, section.body, item[1]);
        });
      });
      bar.appendChild(button);
    });

    return bar;
  }

  function addControls(root, sections) {
    var title = root.querySelector("h1");

    if (title && title.parentElement === root) {
      title.after(makeControls(sections));
    } else {
      root.insertBefore(makeControls(sections), root.firstChild);
    }

    root.appendChild(makeControls(sections));
  }

  // A link or search hit may point inside a closed section, so open its ancestors.
  function revealTarget() {
    if (!location.hash) {
      return;
    }

    var target = document.getElementById(decodeURIComponent(location.hash.slice(1)));
    if (!target) {
      return;
    }

    var node = target;
    while (node && node !== document.body) {
      if (node.classList && node.classList.contains("collapsible-body") && node.hidden) {
        setState(node.previousElementSibling, node, false);
      }
      node = node.parentElement;
    }

    var ownBody = target.nextElementSibling;
    if (target.classList.contains("collapsible-heading") && ownBody && ownBody.hidden) {
      setState(target, ownBody, false);
    }

    target.scrollIntoView();
  }

  function init() {
    var root = document.querySelector("article.md-content__inner");
    if (root) {
      var sections = makeCollapsible(root);
      if (sections.length) {
        addControls(root, sections);
      }
      revealTarget();
    }
  }

  window.addEventListener("hashchange", revealTarget);

  if (typeof document$ !== "undefined") {
    document$.subscribe(init);
  } else {
    document.addEventListener("DOMContentLoaded", init);
  }
})();
