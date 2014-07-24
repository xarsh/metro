[projector, camera, scene, renderer, controls, obj] = [null, null, null, null, null, null]
[lineGroup, stationGroup] = [new THREE.Object3D(), new THREE.Object3D]
transferList = {}
color = {"銀座": 0xf39700, "丸ノ内":0xe60012, "日比谷":0x9caeb7, \
         "東西": 0x00a7db, "千代田":0x009944, "有楽町":0xd7c447, \
         "南北": 0x00ada9, "半蔵門":0x9b7cb6, "副都心":0xbb641d}
normalizedMouse = {x:0, y:0}
currentMouse = {x:0, y:0}
onStation = false
vue = new Vue({ el: '.station-detail' })


init = ->
  projector = new THREE.Projector()

  camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 1, 10000)
  camera.position.set(200, -1000, 1000)

  controls = new THREE.OrbitControls(camera)
  controls.target = new THREE.Vector3(40, -300, 0)
  controls.addEventListener('change', render)

  scene = new THREE.Scene()
  scene.add new THREE.DirectionalLight(0x444444)

  renderer = new THREE.WebGLRenderer({antialias: true})
  renderer.setSize window.innerWidth, window.innerHeight
  document.body.appendChild renderer.domElement
  window.addEventListener('resize', onWindowResize, false)
  window.addEventListener('mousemove', onWindowMouseMove, false)
  window.addEventListener('mousedown', onWindowMouseDown, false)


onWindowResize = ->
  renderer.setSize(window.innerWidth, window.innerHeight)
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()


onWindowMouseMove = (e) ->
  currentMouse = {x:e.clientX, y:e.clientY}
  normalizedMouse.x =  (e.clientX / window.innerWidth) * 2 - 1
  normalizedMouse.y = -(e.clientY / window.innerHeight) * 2 + 1


onWindowMouseDown = (e) ->
  if(onStation)
    vue.stationName =  obj.station.station_name
    vue.stationSubName = obj.station.stationSubName
    vue.stationAddress = obj.station.stationAddress
    vue.lines = ({line: l} for l in transferList[obj.station.station_name])
    $('.station-detail').addClass("opened")


animate = ->
  requestAnimationFrame animate
  controls.update()
  update()


render = ->
  renderer.render scene, camera


prepare = ->
  $ ->
    $.getJSON('./js/lines.json', (lines)=>
      for lineName, stations of lines
        path = new THREE.SplineCurve3(new THREE.Vector3(s.lon, s.lat, s.alt) for s in stations when !s.hidden)
        tube = new THREE.TubeGeometry(path, 96, 3, 12, false, false)
        lineGroup.add new THREE.Mesh(tube, new THREE.MeshLambertMaterial(emissive: color[lineName] || 0xe60012))

        for index, s of stations
          mesh = new THREE.Mesh(new THREE.SphereGeometry(6, 8, 8), new THREE.MeshLambertMaterial(emissive: 0xffffff))
          mesh.station = s
          mesh.position.set(s.lon, s.lat, s.alt)
          stationGroup.add(mesh)
          transferList[s.station_name] ?= []
          transferList[s.station_name].push(lineName)
      render())

  scene.add(lineGroup)
  scene.add(stationGroup)


update = ->
  vector = new THREE.Vector3(normalizedMouse.x, normalizedMouse.y, 1)
  projector.unprojectVector(vector, camera)
  ray = new THREE.Raycaster()
  ray.set(camera.position, vector.sub(camera.position).normalize())
  obj = ray.intersectObjects(stationGroup.children, false)

  if(obj.length > 0)
    obj = obj[0].object
    onStation = true
    $ ->
      $('.tooltip').css({left:currentMouse.x, top:currentMouse.y - 20, display:'block'}).text(obj.station.station_name)
  else
    onStation = false
    $ ->
      $('.tooltip').css({display:'none'})


$ ->
  $('.title li:nth-child(1) a').click ->
    stationGroup.visible = !stationGroup.visible

  $('.title li:nth-child(2) a').click ->
    lineGroup.visible = !lineGroup.visible

  $('.title li:nth-child(3) a').click ->
    $('.station-detail').toggleClass("opened")



init()
animate()
prepare()

