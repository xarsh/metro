[projector, camera, scene, renderer, controls, obj, currentMouse] = [null, null, null, null, null, null, null]
[lineGroup, stationGroup] = [new THREE.Object3D(), new THREE.Object3D]

mouse = {x:0, y:0}

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


onWindowResize = ->
  renderer.setSize(window.innerWidth, window.innerHeight)
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()


onWindowMouseMove = (e) ->
  currentMouse = {x:e.clientX, y:e.clientY}
  mouse.x =  (e.clientX / window.innerWidth) * 2 - 1
  mouse.y = -((e.clientY - 15) / window.innerHeight) * 2 + 1


animate = ->
  requestAnimationFrame animate
  controls.update()
  update()


render = ->
  renderer.render scene, camera


draw = ->
  color = {"ginza":   0xf39700, "marunouchi":0xe60012, "hibiya":    0x9caeb7, \
           "tozai":   0x00a7db, "chiyoda":   0x009944, "yurakucho": 0xd7c447, \
           "hanzomon":0x9b7cb6, "namboku":   0x00ada9, "fukutoshin":0xbb641d}
  $ ->
    $.getJSON('./js/lines.json', (lines)=>
      for lineName, stations of lines
        path = new THREE.SplineCurve3(new THREE.Vector3(s.lon, s.lat, s.alt) for s in stations when !s.hidden)
        tube = new THREE.TubeGeometry(path, 96, 3, 12, false, false)
        lineGroup.add new THREE.Mesh(tube, new THREE.MeshLambertMaterial(emissive: color[lineName] || 0xe60012))

        for index, s of stations
          mesh = new THREE.Mesh(new THREE.SphereGeometry(6, 8, 8), new THREE.MeshLambertMaterial(emissive: 0xffffff))
          mesh.stationName = s.station_name
          mesh.position.set(s.lon, s.lat, s.alt)
          stationGroup.add(mesh))

  scene.add(lineGroup)
  scene.add(stationGroup)


update = ->
  vector = new THREE.Vector3(mouse.x, mouse.y, 1)
  projector.unprojectVector(vector, camera)
  ray = new THREE.Raycaster()
  ray.set(camera.position, vector.sub(camera.position).normalize())
  obj = ray.intersectObjects(stationGroup.children, false)

  if(obj.length > 0)
    obj = obj[0].object
    $ ->
      $('.tooltip').css({left:currentMouse.x, top:currentMouse.y - 20, display:'block'}).text(obj.stationName)
    console.log(obj.stationName)
  else
    obj = null
    $ ->
      $('.tooltip').css({display:'none'})


$ ->
  $('p:nth-child(2) a').click ->
    stationGroup.visible = !stationGroup.visible

  $('p:nth-child(3) a').click ->
    lineGroup.visible = !lineGroup.visible



init()
animate()
draw()
