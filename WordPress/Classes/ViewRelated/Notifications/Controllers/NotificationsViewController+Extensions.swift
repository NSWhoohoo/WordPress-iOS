import Foundation
import Simperium
import WordPressComAnalytics
import WordPress_AppbotX
import WordPressShared



// MARK: - User Interface Initialization
//
extension NotificationsViewController
{
    func setupNavigationBar() {
        // Don't show 'Notifications' in the next-view back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: String(), style: .Plain, target: nil, action: nil)

        // This is only required for debugging:
        // If we're sync'ing against a custom bucket, we should let the user know about it!
        let bucketName = Notification.classNameWithoutNamespaces()
        let overridenName = simperium.bucketOverrides[bucketName] as? String ?? WPNotificationsBucketName

        guard overridenName != WPNotificationsBucketName else {
            return
        }

        title = "Notifications from [\(overridenName)]"
    }

    func setupConstraints() {
        precondition(ratingsHeightConstraint != nil)

        // Ratings is initially hidden!
        ratingsHeightConstraint.constant = 0
    }

    func setupTableView() {
        // Register the cells
        let nibNames = [ NoteTableViewCell.classNameWithoutNamespaces() ]
        let bundle = NSBundle.mainBundle()

        for nibName in nibNames {
            let nib = UINib(nibName: nibName, bundle: bundle)
            tableView.registerNib(nib, forCellReuseIdentifier: nibName)
        }

        // UITableView
        tableView.accessibilityIdentifier  = "Notifications Table"
        WPStyleGuide.configureColorsForView(view, andTableView:tableView)
    }

    func setupTableHeaderView() {
        precondition(tableHeaderView != nil)

        // Fix: Update the Frame manually: Autolayout doesn't really help us, when it comes to Table Headers
        let requiredSize        = tableHeaderView.systemLayoutSizeFittingSize(view.bounds.size)
        var headerFrame         = tableHeaderView.frame
        headerFrame.size.height = requiredSize.height

        tableHeaderView.frame  = headerFrame
        tableHeaderView.layoutIfNeeded()

        // Due to iOS awesomeness, unless we re-assign the tableHeaderView, iOS might never refresh the UI
        tableView.tableHeaderView = tableHeaderView
        tableView.setNeedsLayout()
    }

    func setupTableFooterView() {
        //  Fix: Hide the cellSeparators, when the table is empty
        tableView.tableFooterView = UIView()
    }

    func setupTableHandler() {
        let handler = WPTableViewHandler(tableView: tableView)
        handler.cacheRowHeights = true
        handler.delegate = self
        tableViewHandler = handler
    }

    func setupRatingsView() {
        precondition(ratingsView != nil)

        let ratingsSize = CGFloat(15.0)
        let ratingsFont = WPFontManager.systemRegularFontOfSize(ratingsSize)

        ratingsView.label.font = ratingsFont
        ratingsView.leftButton.titleLabel?.font = ratingsFont
        ratingsView.rightButton.titleLabel?.font = ratingsFont
        ratingsView.delegate = self
        ratingsView.alpha = WPAlphaZero
    }

    func setupRefreshControl() {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        refreshControl = control
    }

    func setupFiltersSegmentedControl() {
        precondition(filtersSegmentedControl != nil)

        let titles = [
            NSLocalizedString("All", comment: "Displays all of the Notifications, unfiltered"),
            NSLocalizedString("Unread", comment: "Filters Unread Notifications"),
            NSLocalizedString("Comments", comment: "Filters Comments Notifications"),
            NSLocalizedString("Follows", comment: "Filters Follows Notifications"),
            NSLocalizedString("Likes", comment: "Filters Likes Notifications")
        ]

        for (index, title) in titles.enumerate() {
            filtersSegmentedControl.setTitle(title, forSegmentAtIndex: index)
        }

        WPStyleGuide.configureSegmentedControl(filtersSegmentedControl)
    }

    func setupNotificationsBucketDelegate() {
        let notesBucket = simperium.bucketForName(entityName())
        notesBucket.delegate = simperiumBucketDelegate()
        notesBucket.notifyWhileIndexing = true
    }
}



// MARK: - UIRefreshControl Methods
//
extension NotificationsViewController
{
    func refresh() {
        // Yes. This is dummy. Simperium handles sync for us!
        refreshControl?.endRefreshing()
    }
}



// MARK: - UISegmentedControl Methods
//
extension NotificationsViewController
{
    func segmentedControlDidChange(sender: UISegmentedControl) {
        reloadResultsController()

        // It's a long way, to the top (if you wanna rock'n roll!)
        guard tableViewHandler.resultsController.fetchedObjects?.count != 0 else {
            return
        }

        let path = NSIndexPath(forRow: 0, inSection: 0)
        tableView.scrollToRowAtIndexPath(path, atScrollPosition: .Bottom, animated: true)
    }
}



// MARK: - WPTableViewHandlerDelegate Methods
//
extension NotificationsViewController: WPTableViewHandlerDelegate
{
    public func managedObjectContext() -> NSManagedObjectContext {
        return ContextManager.sharedInstance().mainContext
    }

    public func fetchRequest() -> NSFetchRequest {
        return NSFetchRequest()
//        let sortKey = NSStringFromSelector(#selector(Notification.timestamp))
        //    NSString *sortKey               = NSStringFromSelector(@selector(timestamp));
        //    NSFetchRequest *fetchRequest    = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
        //    fetchRequest.sortDescriptors    = @[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:NO] ];
        //    fetchRequest.predicate          = [self predicateForSelectedFilters];
        //
//            return fetchRequest
    }

    public func predicateForSelectedFilters() -> NSPredicate {
        return NSPredicate()
        //    NSDictionary *filtersMap = @{
        //        @(NotificationFilterUnread)     : @" AND (read = NO)",
        //        @(NotificationFilterComment)    : [NSString stringWithFormat:@" AND (type = '%@')", NoteTypeComment],
        //        @(NotificationFilterFollow)     : [NSString stringWithFormat:@" AND (type = '%@')", NoteTypeFollow],
        //        @(NotificationFilterLike)       : [NSString stringWithFormat:@" AND (type = '%@' OR type = '%@')",
        //                                            NoteTypeLike, NoteTypeCommentLike]
        //    };
        //
        //    NSString *condition = filtersMap[@(self.filtersSegmentedControl.selectedSegmentIndex)] ?: [NSString string];
        //    NSString *format    = [@"NOT (SELF IN %@)" stringByAppendingString:condition];
        //
        //    return [NSPredicate predicateWithFormat:format, self.notificationIdsBeingDeleted.allObjects];
    }

    public func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        //    // Note:
        //    // iOS 8 has a nice bug in which, randomly, the last cell per section was getting an extra separator.
        //    // For that reason, we draw our own separators.
        //
        //    Notification *note              = [self.tableViewHandler.resultsController objectAtIndexPath:indexPath];
        //    BOOL isMarkedForDeletion        = [self isNoteMarkedForDeletion:note.objectID];
        //    BOOL isLastRow                  = [self isRowLastRowForSection:indexPath];
        //    __weak __typeof(self) weakSelf  = self;
        //
        //    cell.attributedSubject          = note.subjectBlock.attributedSubjectText;
        //    cell.attributedSnippet          = note.snippetBlock.attributedSnippetText;
        //    cell.read                       = note.read.boolValue;
        //    cell.noticon                    = note.noticon;
        //    cell.unapproved                 = note.isUnapprovedComment;
        //    cell.markedForDeletion          = isMarkedForDeletion;
        //    cell.showsBottomSeparator       = !isLastRow && !isMarkedForDeletion;
        //    cell.selectionStyle             = isMarkedForDeletion ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
        //    cell.onUndelete                 = ^{
        //        [weakSelf cancelDeletionForNoteWithID:note.objectID];
        //    };
        //
        //    [cell downloadIconWithURL:note.iconURL];
    }

    public func sectionNameKeyPath() -> String {
        return NSStringFromSelector(#selector(Notification.sectionIdentifier))
    }

    public func entityName() -> String {
        return Notification.classNameWithoutNamespaces()
    }

    public func tableViewDidChangeContent(tableView: UITableView) {
        //    // Update Separators:
        //    // Due to an UIKit bug, we need to draw our own separators (Issue #2845). Let's update the separator status
        //    // after a DB OP. This loop has been measured in the order of milliseconds (iPad Mini)
        //    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows)
        //    {
        //        NoteTableViewCell *cell     = (NoteTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        //        cell.showsBottomSeparator   = ![self isRowLastRowForSection:indexPath];
        //    }
        //
        //    // Update NoResults View
        //    [self showNoResultsViewIfNeeded];
    }
}



// MARK: - RatingsView Helpers
//
extension NotificationsViewController
{
    public func showRatingViewIfApplicable() {
        guard AppRatingUtility.shouldPromptForAppReviewForSection(RatingSettings.section) else {
            return
        }

        guard ratingsHeightConstraint.constant != RatingSettings.heightFull && ratingsView.alpha != WPAlphaFull else {
            return
        }

        ratingsView.alpha = WPAlphaZero

        UIView.animateWithDuration(WPAnimationDurationDefault, delay: RatingSettings.animationDelay, options: .CurveEaseIn, animations: {
            self.ratingsView.alpha = WPAlphaFull
            self.ratingsHeightConstraint.constant = RatingSettings.heightFull

            self.setupTableHeaderView()
        }, completion: nil)

        WPAnalytics.track(.AppReviewsSawPrompt)
    }

    public func hideRatingView() {
        UIView.animateWithDuration(WPAnimationDurationDefault) {
            self.ratingsView.alpha = WPAlphaZero
            self.ratingsHeightConstraint.constant = RatingSettings.heightZero

            self.setupTableHeaderView()
        }
    }
}



// MARK: - ABXPromptViewDelegate Methods
//
extension NotificationsViewController: ABXPromptViewDelegate
{
    public func appbotPromptForReview() {
        WPAnalytics.track(.AppReviewsRatedApp)
        AppRatingUtility.ratedCurrentVersion()
        hideRatingView()

        if let targetURL = NSURL(string: RatingSettings.reviewURL) {
            UIApplication.sharedApplication().openURL(targetURL)
        }
    }

    public func appbotPromptForFeedback() {
        WPAnalytics.track(.AppReviewsOpenedFeedbackScreen)
        ABXFeedbackViewController.showFromController(self, placeholder: nil, delegate: nil)
        AppRatingUtility.gaveFeedbackForCurrentVersion()
        hideRatingView()
    }

    public func appbotPromptClose() {
        WPAnalytics.track(.AppReviewsDeclinedToRateApp)
        AppRatingUtility.declinedToRateCurrentVersion()
        hideRatingView()
    }

    public func appbotPromptLiked() {
        WPAnalytics.track(.AppReviewsLikedApp)
        AppRatingUtility.likedCurrentVersion()
    }

    public func appbotPromptDidntLike() {
        WPAnalytics.track(.AppReviewsDidntLikeApp)
        AppRatingUtility.dislikedCurrentVersion()
    }

    public func abxFeedbackDidSendFeedback () {
        WPAnalytics.track(.AppReviewsSentFeedback)
    }

    public func abxFeedbackDidntSendFeedback() {
        WPAnalytics.track(.AppReviewsCanceledFeedbackScreen)
    }
}



// MARK: - Private Properties
//
private extension NotificationsViewController
{
    var simperium: Simperium {
        return WordPressAppDelegate.sharedInstance().simperium
    }

    struct RatingSettings {
        static let section          = "notifications"
        static let heightFull       = CGFloat(100)
        static let heightZero       = CGFloat(0)
        static let animationDelay   = NSTimeInterval(0.5)
        static let reviewURL        = AppRatingUtility.appReviewUrl()
    }
}
