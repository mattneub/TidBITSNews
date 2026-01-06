@testable import TidBITSRSS26
import Testing
import UIKit
import WaitWhile

private struct MasterViewControllerTests {
    let subject = MasterViewController()
    let processor = MockProcessor<MasterAction, MasterState, MasterEffect>()
    let datasource = MockMasterDatasource()

    init() {
        subject.processor = processor
        subject.datasource = datasource
    }

    @Test("datasource is correctly constructed")
    func datasourceConstruction() throws {
        let subject = MasterViewController()
        let processor = MockProcessor<MasterAction, MasterState, Void>()
        subject.processor = processor
        let datasource = try #require(subject.datasource as? MasterDatasource)
        #expect(datasource.tableView === subject.tableView)
        #expect(datasource.processor === subject.processor)
    }

    @Test("spinner is correctly constructed")
    func spinner() {
        let spinner = subject.spinner
        #expect(spinner.style == .large)
        #expect(spinner.color == .black)
        #expect(spinner.translatesAutoresizingMaskIntoConstraints == false)
    }

    @Test("refresher is correctly constructed")
    func refresher() {
        let refresher = subject.refresher
        #expect(refresher.backgroundColor == UIColor(red: 0.251, green: 0, blue: 0.502, alpha: 1))
        #expect(refresher.tintColor == .white)
        #expect(refresher.actions(forTarget: subject, forControlEvent: .valueChanged)?.first == "doRefresh:")
    }

    @Test("viewDidLoad: background color is correct")
    func backgroundColor() throws {
        subject.loadViewIfNeeded()
        let color = try #require(subject.view.backgroundColor)
        #expect(color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)) == UIColor.myPurple * 0.4 + UIColor.white * 0.6)
        #expect(color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)) == UIColor.myPurple * 0.8 + UIColor.black * 0.2)
    }

    @Test("viewDidLoad: logo view is correct")
    func logo() throws {
        subject.loadViewIfNeeded()
        let imageView = try #require(subject.navigationItem.titleView as? UIImageView)
        #expect(imageView is MyAccessibleNoActionImageView)
        #expect(imageView.image == UIImage(named: "tb_iphone_banner"))
        #expect(imageView.contentMode == .center)
        #expect(imageView.translatesAutoresizingMaskIntoConstraints == false)
        #expect(imageView.constraints[0].firstAttribute == .height)
        #expect(imageView.constraints[0].constant == 58)
        #expect(imageView.isUserInteractionEnabled == true)
        let tapper = try #require(imageView.gestureRecognizers?.first as? MyTapGestureRecognizer)
        #expect(tapper.target === subject)
        #expect(tapper.action == #selector(subject.logoTapped))
    }

    @Test("viewDidLoad: table view edge is hard, clearsSelection is false")
    func tableViewEdge() {
        subject.loadViewIfNeeded()
        #expect(subject.tableView.topEdgeEffect.style == .hard)
        #expect(subject.clearsSelectionOnViewWillAppear == false)
    }

    @Test("viewDidLoad: configures backBarButton")
    func backBarButton() throws {
        subject.loadViewIfNeeded()
        #expect(subject.navigationItem.title == "TidBITS")
        let button = try #require(subject.navigationItem.backBarButtonItem)
        #expect(button.title == "TidBITS")
        #expect(button.tintColor == .myPurple)
    }

    @Test("viewDidLoad: sets up refresh control, spinner spins")
    func refreshAndSpinner() {
        subject.loadViewIfNeeded()
        #expect(subject.refreshControl === subject.refresher)
        #expect(subject.spinner.isAnimating)
        #expect(subject.spinner.isDescendant(of: subject.view))
    }

    @Test("viewDidAppear: sends processor viewDidAppear")
    func viewDidAppear() async {
        subject.viewDidAppear(false)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.viewDidAppear])
    }

    @Test("present: presents to the datasource")
    func present() async {
        await subject.present(MasterState())
        #expect(datasource.state == MasterState())
    }

    @Test("present: removes spinner, stops and configures refresher")
    func presentSpinnerRefresher() async {
        makeWindow(viewController: subject)
        #expect(subject.spinner.isDescendant(of: subject.view))
        let state = MasterState(lastNetworkFetchDate: .now)
        subject.refresher.beginRefreshing()
        await subject.present(state)
        #expect(!subject.spinner.isDescendant(of: subject.view))
        #expect(!subject.refresher.isRefreshing)
        #expect(subject.refresher.attributedTitle == NSAttributedString(state.lastNetworkFetchDateStringAttributed!))
    }

    @Test("receive: passes to the datasource")
    func receive() async {
        await subject.receive(.select(0))
        #expect(datasource.thingsReceived == [.select(0)])
    }

    @Test("doRefresh: sends fetchFeed with forceNetwork true")
    func doRefresh() async {
        makeWindow(viewController: subject)
        await #while(processor.thingsReceived.count < 2) // appearing, viewDidAppear
        processor.thingsReceived = []
        subject.refresher.beginRefreshing()
        subject.doRefresh(subject.refresher)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.fetchFeed(forceNetwork: true)])
    }
}
