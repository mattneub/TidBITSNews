@testable import TidBITSRSS26
import Testing
import UIKit
import WaitWhile

private struct MasterViewControllerTests {
    let subject = MasterViewController()
    let processor = MockProcessor<MasterAction, MasterState, Void>()
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

    @Test("viewDidLoad: table view edge is hard")
    func tableViewEdge() {
        subject.loadViewIfNeeded()
        #expect(subject.tableView.topEdgeEffect.style == .hard)
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
}
