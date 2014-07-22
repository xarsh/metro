[camera, scene, renderer, controls] = [null, null, null, null]

projector = new THREE.Projector()
mouse = {x:0, y:0}
targetList = []

init = ->
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


onWindowResize = ->
  renderer.setSize(window.innerWidth, window.innerHeight)
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()


animate = ->
  requestAnimationFrame animate
  controls.update()


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
        mesh = new THREE.Mesh(tube, new THREE.MeshLambertMaterial(emissive: color[lineName] || 0xe60012))
        scene.add mesh

        for index, s of stations
          mesh = new THREE.Mesh(new THREE.SphereGeometry(6, 12, 12), new THREE.MeshLambertMaterial(emissive: 0xffffff))
          mesh.position.set(s.lon, s.lat, s.alt)
          scene.add(mesh)
          targetList.push(mesh))


window.onmousedown = (ev) ->
  if(ev.target == renderer.domElement)
    rect = ev.target.getBoundingClientRect()
    mouse.x = ev.clientX - rect.left
    mouse.y = ev.clientY - rect.top
    mouse.x =  (mouse.x / window.innerWidth) * 2 - 1
    mouse.y = -(mouse.y / window.innerHeight) * 2 + 1

    vector = new THREE.Vector3(mouse.x, mouse.y, 1)
    projector.unprojectVector(vector, camera)
    ray = new THREE.Raycaster()
    ray.set(camera.position, vector.sub(camera.position).normalize())
    obj = ray.intersectObjects(scene.children, false)

    if(obj.length > 0)
      console.log(obj[0])

init()
animate()
draw()
