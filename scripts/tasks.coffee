#n Description:
#   Allows tasks (TODOs) to be added to Hubot
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot やる <task> - Add a task
#   hubot やること - List the tasks
#   hubot やった <task number> - Delete a task
#
# Author:
#   Crofty

class Tasks
  constructor: (@robot) ->
    @cache = []
    @robot.brain.on 'loaded', =>
      if @robot.brain.data.tasks
        @cache = @robot.brain.data.tasks
  nextTaskNum: ->
    maxTaskNum = if @cache.length then Math.max.apply(Math,@cache.map (n) -> n.num) else 0
    maxTaskNum++
    maxTaskNum
  add: (taskString) ->
    task = {num: @nextTaskNum(), task: taskString}
    @cache.push task
    @robot.brain.data.tasks = @cache
    task
  all: -> @cache
  deleteByNumber: (num) ->
    index = @cache.map((n) -> n.num).indexOf(parseInt(num))
    task = @cache.splice(index, 1)[0]
    @robot.brain.data.tasks = @cache
    task

module.exports = (robot) ->
  tasks = new Tasks robot

  robot.respond /(やる)(　| )(.+?)$/i, (msg) ->
    task = tasks.add msg.match[3]
    msg.send "おしごと追加しましたー: ##{task.num} - #{task.task}"

  robot.respond /(やること)/i, (msg) ->
    if tasks.all().length > 0
      response = ""
      for task, num in tasks.all()
        response += "##{task.num} - #{task.task}\n"
      msg.send response
    else
      msg.send "There are no tasks"

  robot.respond /(やった)(　| )#?(\d+)/i, (msg) ->
    taskNum = msg.match[3]
    task = tasks.deleteByNumber taskNum
    msg.send "おつかれさまです！: ##{task.num} - #{task.task}"
