// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library tracker.web.tracker_app;

import 'package:polymer/polymer.dart';
import 'package:tracker/models.dart';
import 'package:tracker/seed.dart' as seed;

@CustomTag('tracker-app')
class TrackerApp extends PolymerElement {
  get applyAuthorStyles => true;
  @observable final tasks = toObservable([]);
  @observable var app;
  @observable var newTask = new Task.unsaved();
  @observable var searchParam = '';
  @observable var usingForm = false;

  // Buckets for grouping tasks by status.
  @observable var current = toObservable([]);
  @observable var pending = toObservable([]);
  @observable var completed = toObservable([]);



  var filteredOutTasks = [];

  TrackerApp.created() : super.created() {
    appModel.tasks = tasks;

    tasks.changes.listen((changes) {
      _filterTasksByStatus();
    });

    _addSeedData();
  }

  toggleFormDisplay() {
    usingForm = !usingForm;
  }

  showEmptyForm() {
    newTask = new Task.unsaved();
    if (!usingForm) {
      toggleFormDisplay();
    }
  }

  search() {
    tasks.addAll(filteredOutTasks);
    filteredOutTasks.clear();

    for (var task in tasks) {
      if (!taskMatchesSearchParam(task)) {
        filteredOutTasks.add(task);
      }
    }

    for (var task in filteredOutTasks) {
      tasks.remove(task);
    }
  }

  taskMatchesSearchParam(task) {
    var param = searchParam.toLowerCase();
    if (param.isEmpty) return true;
    return task.title.toLowerCase().contains(param) ||
        task.description.toLowerCase().contains(param);
  }

  _addSeedData() {
    for (var i = 0; i < seed.data.length; i++) {
      // Assign IDs to the seed data, so that task.saved == true.
      seed.data[i].taskID = i;
      tasks.add(seed.data[i]);
    }
  }

  _filterTasksByStatus() {
    current = [];
    pending = [];
    completed = [];
    for (var task in tasks) {
      if (task.status == Task.CURRENT) {
        current.add(task);
      } else if (task.status == Task.PENDING) {
        pending.add(task);
      } else {
        completed.add(task);
      }
    }
  }
}

