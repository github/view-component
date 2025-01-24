---
layout: default
title: Overview
nav_order: 1
---

# ViewComponent (v{{ site.data.library.version }})

A framework for creating reusable, testable & encapsulated view components, built to integrate seamlessly with Ruby on Rails.

## What's a ViewComponent?

ViewComponents are Ruby objects used to build markup. Think of them as an evolution of the presenter pattern, inspired by [React](https://reactjs.org/docs/react-component.html).

ViewComponents are objects that encapsulate a template:

```ruby
# app/components/message_component.rb
class MessageComponent < ViewComponent::Base
  def initialize(name:)
    @name = name
  end
end
```

```erb
<%# app/components/message_component.html.erb %>
<h1>Hello, <%= @name %>!<h1>
```

Which is rendered by calling:

```erb
<%# app/views/demo/index.html.erb %>
<%= render(MessageComponent.new(name: "World")) %>
```

Returning:

```html
<h1>Hello, World!</h1>
```

## Why use ViewComponents?

### TL;DR

ViewComponents work best for templates that are reused or benefit from being tested directly. Partials and templates with significant amounts of embedded Ruby often make good ViewComponents.

### Single responsibility

Rails applications often scatter view-related logic across models, controllers, and helpers, diluting their intended responsibilities. ViewComponents consolidate the logic needed for a template into a single class, resulting in a cohesive object that is easy to understand.

ViewComponent methods are implemented within the scope of the template, encapsulating them in proper object-oriented fashion. This cohesion is especially evident when multiple methods are needed for a single view.

### Testing

ViewComponent was designed with the intention that all components should be unit tested. In the GitHub codebase, ViewComponent unit tests are over 100x faster than similar controller tests.

With ViewComponent, integration tests can be reserved for end-to-end assertions, with permutations covered at the unit level.

For example, to test the `MessageComponent` above:

```ruby
class MessageComponentTest < GitHub::TestCase
  include ViewComponent::TestHelpers

  test "renders message" do
    render_inline(MessageComponent.new(name: "World"))

    assert_selector "h1", text: "Hello, World!"
  end
end
```

ViewComponent unit tests leverage the Capybara matchers library, allowing for complex assertions traditionally reserved for controller and browser tests.

### Data Flow

Traditional Rails templates have an implicit interface, making it hard to reason about their dependencies. This can lead to subtle bugs when rendering the same template in different contexts.

ViewComponents use a standard Ruby initializer that clearly defines what's needed to render, making reuse easier and safer than partials.

### Performance

Based on several [benchmarks](https://github.com/viewcomponent/view_component/blob/main/performance/partial_benchmark.rb), ViewComponents are ~10x faster than partials in real-world use-cases.

The primary optimization is pre-compiling all ViewComponent templates at application boot, instead of at runtime like traditional Rails views.

For example, the `MessageComponent` template is compiled onto the Ruby object:

```ruby
# app/components/message_component.rb
class MessageComponent < ViewComponent::Base
  def initialize(name:)
    @name = name
  end

  def call
    @output_buffer.safe_append = "<h1>Hello, ".freeze
    @output_buffer.append = (@name)
    @output_buffer.safe_append = "!</h1>".freeze
    @output_buffer.to_s
  end
end
```

### Code quality

Template code often fails basic Ruby standards: long methods, deep conditional nesting, and mystery guests abound.

ViewComponents are Ruby objects, making it easy to follow (and enforce) code quality standards.

## Contributors

ViewComponent is built by over a hundred members of the community, including:

<img src="https://avatars.githubusercontent.com/nickcoyne?s=64" alt="nickcoyne" width="32" />
<img src="https://avatars.githubusercontent.com/nachiket87?s=64" alt="nachiket87" width="32" />
<img src="https://avatars.githubusercontent.com/andrewjtait?s=64" alt="andrewjtait" width="32" />
<img src="https://avatars.githubusercontent.com/asgerb?s=64" alt="asgerb" width="32" />
<img src="https://avatars.githubusercontent.com/bbugh?s=64" alt="bbugh" width="32" />
<img src="https://avatars.githubusercontent.com/bigbigdoudou?s=64" alt="bigbigdoudou" width="32" />
<img src="https://avatars.githubusercontent.com/blakewilliams?s=64" alt="blakewilliams" width="32" />
<img src="https://avatars.githubusercontent.com/boardfish?s=64" alt="boardfish" width="32" />
<img src="https://avatars.githubusercontent.com/bobmaerten?s=64" alt="bobmaerten" width="32" />
<img src="https://avatars.githubusercontent.com/bpo?s=64" alt="bpo" width="32" />
<img src="https://avatars.githubusercontent.com/bradparker?s=64" alt="bradparker" width="32" />
<img src="https://avatars.githubusercontent.com/cesariouy?s=64" alt="cesariouy" width="32" />
<img src="https://avatars.githubusercontent.com/cover?s=64" alt="cover" width="32" />
<img src="https://avatars.githubusercontent.com/cpjmcquillan?s=64" alt="cpjmcquillan" width="32" />
<img src="https://avatars.githubusercontent.com/crookedgrin?s=64" alt="crookedgrin" width="32" />
<img src="https://avatars.githubusercontent.com/czj?s=64" alt="czj" width="32" />
<img src="https://avatars.githubusercontent.com/dani-sc?s=64" alt="dani-sc" width="32" />
<img src="https://avatars.githubusercontent.com/danieldiekmeier?s=64" alt="danieldiekmeier" width="32" />
<img src="https://avatars.githubusercontent.com/danielnc?s=64" alt="danielnc" width="32" />
<img src="https://avatars.githubusercontent.com/dark-panda?s=64" alt="dark-panda" width="32" />
<img src="https://avatars.githubusercontent.com/davekaro?s=64" alt="davekaro" width="32" />
<img src="https://avatars.githubusercontent.com/dixpac?s=64" alt="dixpac" width="32" />
<img src="https://avatars.githubusercontent.com/dukex?s=64" alt="dukex" width="32" />
<img src="https://avatars.githubusercontent.com/dylanatsmith?s=64" alt="dylanatsmith" width="32" />
<img src="https://avatars.githubusercontent.com/dylnclrk?s=64" alt="dylnclrk" width="32" />
<img src="https://avatars.githubusercontent.com/edwinthinks?s=64" alt="edwinthinks" width="32" />
<img src="https://avatars.githubusercontent.com/elia?s=64" alt="elia" width="32" />
<img src="https://avatars.githubusercontent.com/franco?s=64" alt="franco" width="32" />
<img src="https://avatars.githubusercontent.com/franks921?s=64" alt="franks921" width="32" />
<img src="https://avatars.githubusercontent.com/franzliedke?s=64" alt="franzliedke" width="32" />
<img src="https://avatars.githubusercontent.com/fsateler?s=64" alt="fsateler" width="32" />
<img src="https://avatars.githubusercontent.com/fugufish?s=64" alt="fugufish" width="32" />
<img src="https://avatars.githubusercontent.com/g13ydson?s=64" alt="g13ydson" width="32" />
<img src="https://avatars.githubusercontent.com/horacio?s=64" alt="horacio" width="32" />
<img src="https://avatars.githubusercontent.com/horiaradu?s=64" alt="horiaradu" width="32" />
<img src="https://avatars.githubusercontent.com/jacob-carlborg-apoex?s=64" alt="yykamei" width="32" />
<img src="https://avatars.githubusercontent.com/jaredcwhite?s=64" alt="jaredcwhite" width="32" />
<img src="https://avatars.githubusercontent.com/jasonswett?s=64" alt="jasonswett" width="32" />
<img src="https://avatars.githubusercontent.com/javierm?s=64" alt="javierm" width="32" />
<img src="https://avatars.githubusercontent.com/jcoyne?s=64" alt="jcoyne" width="32" />
<img src="https://avatars.githubusercontent.com/jensljungblad?s=64" alt="jensljungblad" width="32" />
<img src="https://avatars.githubusercontent.com/joelhawksley?s=64" alt="joelhawksley" width="32" />
<img src="https://avatars.githubusercontent.com/johannesengl?s=64" alt="johannesengl" width="32" />
<img src="https://avatars.githubusercontent.com/jonspalmer?s=64" alt="jonspalmer" width="32" />
<img src="https://avatars.githubusercontent.com/juanmanuelramallo?s=64" alt="juanmanuelramallo" width="32" />
<img src="https://avatars.githubusercontent.com/jules2689?s=64" alt="jules2689" width="32" />
<img src="https://avatars.githubusercontent.com/jwshuff?s=64" alt="jwshuff" width="32" />
<img src="https://avatars.githubusercontent.com/kaspermeyer?s=64" alt="kaspermeyer" width="32" />
<img src="https://avatars.githubusercontent.com/kylefox?s=64" alt="kylefox" width="32" />
<img src="https://avatars.githubusercontent.com/kdonovan?s=64" alt="kdonovan" width="32" />
<img src="https://avatars.githubusercontent.com/leighhalliday?s=64" alt="leighhalliday" width="32" />
<img src="https://avatars.githubusercontent.com/llenk?s=64" alt="llenk" width="32" />
<img src="https://avatars.githubusercontent.com/manuelpuyol?s=64" alt="manuelpuyol" width="32" />
<img src="https://avatars.githubusercontent.com/matheusrich?s=64" alt="matheusrich" width="32" />
<img src="https://avatars.githubusercontent.com/matt-yorkley?s=64" alt="Matt-Yorkley" width="32" />
<img src="https://avatars.githubusercontent.com/mattbrictson?s=64" alt="mattbrictson" width="32" />
<img src="https://avatars.githubusercontent.com/mattwr18?s=64" alt="mattwr18" width="32" />
<img src="https://avatars.githubusercontent.com/maxbeizer?s=64" alt="maxbeizer" width="32" />
<img src="https://avatars.githubusercontent.com/mellowfish?s=64" alt="mellowfish" width="32" />
<img src="https://avatars.githubusercontent.com/metade?s=64" alt="metade" width="32" />
<img src="https://avatars.githubusercontent.com/michaelem?s=64" alt="michaelem" width="32" />
<img src="https://avatars.githubusercontent.com/mixergtz?s=64" alt="mixergtz" width="32" />
<img src="https://avatars.githubusercontent.com/mrrooijen?s=64" alt="mrrooijen" width="32" />
<img src="https://avatars.githubusercontent.com/nashby?s=64" alt="nashby" width="32" />
<img src="https://avatars.githubusercontent.com/nicolas-brousse?s=64" alt="nicolas-brousse" width="32" />
<img src="https://avatars.githubusercontent.com/nielsslot?s=64" alt="nshki" width="32" />
<img src="https://avatars.githubusercontent.com/nshki?s=64" alt="nshki" width="32" />
<img src="https://avatars.githubusercontent.com/ozydingo?s=64" alt="ozydingo" width="32" />
<img src="https://avatars.githubusercontent.com/p8?s=64" alt="p8" width="32" />
<img src="https://avatars.githubusercontent.com/patrickarnett?s=64" alt="patrickarnett" width="32" />
<img src="https://avatars.githubusercontent.com/rainerborene?s=64" alt="rainerborene" width="32" />
<img src="https://avatars.githubusercontent.com/rdavid1099?s=64" alt="rdavid1099" width="32" />
<img src="https://avatars.githubusercontent.com/richardmarbach?s=64" alt="richardmarbach" width="32" />
<img src="https://avatars.githubusercontent.com/rmacklin?s=64" alt="rmacklin" width="32" />
<img src="https://avatars.githubusercontent.com/ryogift?s=64" alt="ryogift" width="32" />
<img src="https://avatars.githubusercontent.com/sammyhenningsson?s=64" alt="sammyhenningsson" width="32" />
<img src="https://avatars.githubusercontent.com/sampart?s=64" alt="sampart" width="32" />
<img src="https://avatars.githubusercontent.com/seanpdoyle?s=64" alt="seanpdoyle" width="32" />
<img src="https://avatars.githubusercontent.com/sfnelson?s=64" alt="sfnelson" width="32" />
<img src="https://avatars.githubusercontent.com/simonrand?s=64" alt="simonrand" width="32" />
<img src="https://avatars.githubusercontent.com/skryukov?s=64" alt="skryukov" width="32" />
<img src="https://avatars.githubusercontent.com/smashwilson?s=64" alt="smashwilson" width="32" />
<img src="https://avatars.githubusercontent.com/spdawson?s=64" alt="spdawson" width="32" />
<img src="https://avatars.githubusercontent.com/spone?s=64" alt="Spone" width="32" />
<img src="https://avatars.githubusercontent.com/stiig?s=64" alt="stiig" width="32" />
<img src="https://avatars.githubusercontent.com/swanson?s=64" alt="swanson" width="32" />
<img src="https://avatars.githubusercontent.com/tbroad-ramsey?s=64" alt="tbroad-ramsey" width="32" />
<img src="https://avatars.githubusercontent.com/tclem?s=64" alt="tclem" width="32" />
<img src="https://avatars.githubusercontent.com/tenderlove?s=64" alt="tenderlove" width="32" />
<img src="https://avatars.githubusercontent.com/tgaff?s=64" alt="tgaff" width="32" />
<img src="https://avatars.githubusercontent.com/thutterer?s=64" alt="thutterer" width="32" />
<img src="https://avatars.githubusercontent.com/tonkpils?s=64" alt="tonkpils" width="32" />
<img src="https://avatars.githubusercontent.com/traels?s=64" alt="traels" width="32" />
<img src="https://avatars.githubusercontent.com/vinistock?s=64" alt="vinistock" width="32" />
<img src="https://avatars.githubusercontent.com/wdrexler?s=64" alt="wdrexler" width="32" />
<img src="https://avatars.githubusercontent.com/websebdev?s=64" alt="websebdev" width="32" />
<img src="https://avatars.githubusercontent.com/xkraty?s=64" alt="xkraty" width="32" />
<img src="https://avatars.githubusercontent.com/xronos-i-am?s=64" alt="xronos-i-am" width="32" />
<img src="https://avatars.githubusercontent.com/yykamei?s=64" alt="yykamei" width="32" />
<img src="https://avatars.githubusercontent.com/matheuspolicamilo?s=64" alt="matheuspolicamilo" width="32" />
<img src="https://avatars.githubusercontent.com/danigonza?s=64" alt="danigonza" width="32" />
<img src="https://avatars.githubusercontent.com/erinnachen?s=64" alt="erinnachen" width="32" />
<img src="https://avatars.githubusercontent.com/ihollander?s=64" alt="ihollander" width="32" />
<img src="https://avatars.githubusercontent.com/svetlins?s=64" alt="svetlins" width="32" />
<img src="https://avatars.githubusercontent.com/nickmalcolm?s=64" alt="nickmalcolm" width="32" />
<img src="https://avatars.githubusercontent.com/reeganviljoen?s=64" alt="reeganviljoen" width="32" />
<img src="https://avatars.githubusercontent.com/thomascchen?s=64" alt="thomascchen" width="32" />
<img src="https://avatars.githubusercontent.com/milk1000cc?s=64" alt="milk1000cc" width="32" />
<img src="https://avatars.githubusercontent.com/aduth?s=64" alt="aduth" width="32" />
<img src="https://avatars.githubusercontent.com/htcarr3?s=64" alt="htcarr3" width="32" />
<img src="https://avatars.githubusercontent.com/neanias?s=64" alt="neanias" width="32" />
<img src="https://avatars.githubusercontent.com/allan-pires?s=64" alt="allan-pires" width="32" />
<img src="https://avatars.githubusercontent.com/jasonkim?s=64" alt="jasonkim" width="32" />
<img src="https://avatars.githubusercontent.com/tkowalewski" alt="tkowalewski" width="32" />
<img src="https://avatars.githubusercontent.com/chloe-meister" alt="chloe-meister" width="32" />
<img src="https://avatars.githubusercontent.com/zaratan" alt="zaratan" width="32" />
<img src="https://avatars.githubusercontent.com/kawakamimoeki" alt="kawakamimoeki" width="32" />

## Who uses ViewComponent?

* [Aboard HR](https://aboardhr.com/)
* [Arrows](https://arrows.to/)
* [Aluuno](https://aluuno.com/)
* [Avo Admin for Rails](https://avohq.io/rails-admin)
* [Bearer](https://www.bearer.com/) (70+ components)
* [Brightline](https://hellobrightline.com)
* [Buildkite](https://buildkite.com)
* [Bump.sh](https://bump.sh)
* [Causey](https://www.causey.app/) (100+ components)
* [CharlieHR](https://www.charliehr.com/)
* [City of Paris](https://www.paris.fr/)
* [Clio](https://www.clio.com/)
* [Cometeer](https://cometeer.com/)
* [Consul](https://consulproject.org/en/)
* [Cults.](https://cults3d.com/)
* [Defacto](https://www.defacto.nl)
* [DotRuby](https://www.dotruby.com)
* [Eagerworks](https://eagerworks.com/)
* [FlightLogger](https://flightlogger.net/)
* [Framework](https://frame.work/)
* [FreeAgent](https://www.freeagent.com)
* [FreeATS](https://www.freeats.com/)
* [G2](https://www.g2.com/) (200+ components)
* [Getblock](https://getblock.io/)
* [GitHub](https://github.com/) (900+ components used 15k+ times)
* [GitLab](https://gitlab.com/)
* [HappyCo](https://happy.co)
* [Keenly](https://www.keenly.so) (100+ components)
* [Kicksite](https://kicksite.com/)
* [Krystal](https://krystal.uk)
* [Litmus](https://litmus.engineering/)
* [Login.gov](https://github.com/18F/identity-idp)
* [Mission Met Center](https://www.missionmet.com/mission-met-center)
* [Mon Ami](https://www.monami.io)
* [Nikola Motor](https://www.nikolamotor.com/) (50+ components and counting)
* [Niva](https://www.niva.co/)
* [OBLSK](https://oblsk.com/)
* [openSUSE Open Build Service](https://openbuildservice.org/)
* [OpenProject](https://www.openproject.org/)
* [Ophelos](https://ophelos.com)
* [Orbit](https://orbit.love)
* [PeopleForce](https://peopleforce.io)
* [PLT4M](https://plt4m.com/)
* [Podia](https://www.podia.com/)
* [PrintReleaf](https://www.printreleaf.com/)
* [Project Blacklight](http://projectblacklight.org/)
* [QuickNode](https://www.quicknode.com/)
* [Room AI](https://roomai.com/)
* [SearchApi](https://www.searchapi.io/)
* [Simundia](https://www.simundia.com/)
* [Skroutz](https://engineering.skroutz.gr/blog/)
* [Shogun](https://getshogun.com/)
* [SpendHQ](https://www.spendhq.com/)
* [Spina CMS](https://spinacms.com/)
* [Spring](https://spring.net/)
* [Startup Jobs](https://startup.jobs/)
* [Teamtailor](https://teamtailor.com/)
* [Topkey](https://topkey.io/)
* [Wecasa](https://www.wecasa.fr/)
* [WIP](https://wip.co/)
* [Within3](https://www.within3.com/)
* [Workbrew](https://www.workbrew.com/)
* [Wrapbook](https://wrapbook.com/)
* [Yobbers](https://www.yobbers.com/)

Using ViewComponent? [Send a pull request](https://github.com/viewcomponent/view_component/edit/main/docs/index.md) to update this list!
You can also check out [how various projects use ViewComponent](https://github.com/viewcomponent/view_component/network/dependents?package_id=UGFja2FnZS0xMDEwNjQxMzYx).

<hr />

[Getting started →](/guide/getting-started.html)
